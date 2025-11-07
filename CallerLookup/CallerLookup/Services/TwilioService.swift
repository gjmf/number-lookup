//
//  TwilioService.swift
//  CallerLookup
//
//  Service for interacting with Twilio Lookup API
//

import Foundation
import Combine

enum TwilioError: LocalizedError {
    case notConfigured
    case invalidPhoneNumber
    case networkError(Error)
    case apiError(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Twilio credentials not configured. Please set up your Account SID and Auth Token in Settings."
        case .invalidPhoneNumber:
            return "Invalid phone number format. Please include country code (e.g., +12223334444)."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let message):
            return "API error: \(message)"
        case .invalidResponse:
            return "Invalid response from Twilio API."
        }
    }
}

class TwilioService: ObservableObject {
    static let shared = TwilioService()

    @Published var accountSID: String?
    @Published var authToken: String?
    @Published var lookupHistory: [LookupResult] = []

    private let userDefaults: UserDefaults
    private let historyKey = "lookupHistory"
    private let sidKey = "twilioAccountSID"
    private let tokenKey = "twilioAuthToken"

    var isConfigured: Bool {
        accountSID != nil && authToken != nil &&
        !(accountSID?.isEmpty ?? true) && !(authToken?.isEmpty ?? true)
    }

    init() {
        // Use App Group for sharing data with extension
        if let groupDefaults = UserDefaults(suiteName: "group.com.callerlookup.shared") {
            self.userDefaults = groupDefaults
        } else {
            self.userDefaults = UserDefaults.standard
        }

        loadCredentials()
        loadHistory()
    }

    func configure(accountSID: String, authToken: String) {
        self.accountSID = accountSID
        self.authToken = authToken

        userDefaults.set(accountSID, forKey: sidKey)
        userDefaults.set(authToken, forKey: tokenKey)
        userDefaults.synchronize()
    }

    func lookupPhoneNumber(_ phoneNumber: String) async throws -> LookupResult {
        guard isConfigured, let sid = accountSID, let token = authToken else {
            throw TwilioError.notConfigured
        }

        // Validate phone number format
        let cleanNumber = phoneNumber.trimmingCharacters(in: .whitespaces)
        guard cleanNumber.hasPrefix("+") && cleanNumber.count >= 10 else {
            throw TwilioError.invalidPhoneNumber
        }

        // Build URL with multiple lookup types
        let encodedNumber = cleanNumber.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? cleanNumber
        let baseURL = "https://lookups.twilio.com/v1/PhoneNumbers/\(encodedNumber)/"

        // First try with basic carrier and caller-name lookup
        let basicURL = baseURL + "?Type=carrier&Type=caller-name"

        do {
            let basicResult = try await performLookup(url: basicURL, accountSID: sid, authToken: token)

            // Optionally try add-ons (these may cost extra)
            // Uncomment if you want to use Twilio add-ons:
            // let opencnamResult = try? await performLookup(
            //     url: baseURL + "?AddOns=telo_opencnam",
            //     accountSID: sid,
            //     authToken: token
            // )
            // let trestleResult = try? await performLookup(
            //     url: baseURL + "?AddOns=trestle_reverse_phone",
            //     accountSID: sid,
            //     authToken: token
            // )

            return LookupResult.from(twilioResponse: basicResult, phoneNumber: cleanNumber)
        } catch {
            throw TwilioError.networkError(error)
        }
    }

    private func performLookup(url: String, accountSID: String, authToken: String) async throws -> [String: Any] {
        guard let requestURL = URL(string: url) else {
            throw TwilioError.invalidPhoneNumber
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"

        // Add Basic Auth
        let credentials = "\(accountSID):\(authToken)"
        if let credentialsData = credentials.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TwilioError.invalidResponse
        }

        if httpResponse.statusCode == 404 {
            throw TwilioError.invalidPhoneNumber
        }

        if httpResponse.statusCode != 200 {
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorDict["message"] as? String {
                throw TwilioError.apiError(message)
            }
            throw TwilioError.apiError("HTTP \(httpResponse.statusCode)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw TwilioError.invalidResponse
        }

        return json
    }

    // MARK: - History Management

    func addToHistory(_ result: LookupResult) {
        lookupHistory.append(result)
        saveHistory()

        // Also save to shared defaults for the extension
        saveResultForExtension(result)
    }

    func removeFromHistory(at index: Int) {
        guard index < lookupHistory.count else { return }
        lookupHistory.remove(at: index)
        saveHistory()
    }

    func clearHistory() {
        lookupHistory.removeAll()
        saveHistory()
    }

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(lookupHistory) {
            userDefaults.set(encoded, forKey: historyKey)
            userDefaults.synchronize()
        }
    }

    private func loadHistory() {
        if let data = userDefaults.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([LookupResult].self, from: data) {
            lookupHistory = decoded
        }
    }

    private func loadCredentials() {
        accountSID = userDefaults.string(forKey: sidKey)
        authToken = userDefaults.string(forKey: tokenKey)
    }

    // MARK: - Extension Support

    private func saveResultForExtension(_ result: LookupResult) {
        var savedResults = loadSavedResults()
        savedResults.append(result)

        // Keep only recent results (last 1000)
        if savedResults.count > 1000 {
            savedResults = Array(savedResults.suffix(1000))
        }

        if let encoded = try? JSONEncoder().encode(savedResults) {
            userDefaults.set(encoded, forKey: "extensionResults")
            userDefaults.synchronize()
        }
    }

    private func loadSavedResults() -> [LookupResult] {
        if let data = userDefaults.data(forKey: "extensionResults"),
           let decoded = try? JSONDecoder().decode([LookupResult].self, from: data) {
            return decoded
        }
        return []
    }
}
