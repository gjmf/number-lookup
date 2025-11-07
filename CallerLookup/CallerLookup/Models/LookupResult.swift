//
//  LookupResult.swift
//  CallerLookup
//
//  Model for phone number lookup results
//

import Foundation

struct LookupResult: Identifiable, Codable {
    let id: UUID
    let phoneNumber: String
    let callerName: String?
    let carrierName: String?
    let lineType: String?
    let countryCode: String?
    let additionalInfo: [String: String]
    let timestamp: Date

    init(
        id: UUID = UUID(),
        phoneNumber: String,
        callerName: String? = nil,
        carrierName: String? = nil,
        lineType: String? = nil,
        countryCode: String? = nil,
        additionalInfo: [String: String] = [:],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.callerName = callerName
        self.carrierName = carrierName
        self.lineType = lineType
        self.countryCode = countryCode
        self.additionalInfo = additionalInfo
        self.timestamp = timestamp
    }

    // Parse from Twilio API response
    static func from(twilioResponse: [String: Any], phoneNumber: String) -> LookupResult {
        var callerName: String?
        var carrierName: String?
        var lineType: String?
        var countryCode: String?
        var additionalInfo: [String: String] = [:]

        // Extract caller name
        if let callerNameData = twilioResponse["caller_name"] as? [String: Any],
           let name = callerNameData["caller_name"] as? String {
            callerName = name
        }

        // Extract carrier info
        if let carrier = twilioResponse["carrier"] as? [String: Any] {
            if let name = carrier["name"] as? String {
                carrierName = name
            }
            if let type = carrier["type"] as? String {
                lineType = type.capitalized
            }
        }

        // Extract country code
        if let code = twilioResponse["country_code"] as? String {
            countryCode = code
        }

        // Extract add-on results
        if let addOns = twilioResponse["add_ons"] as? [String: Any],
           let results = addOns["results"] as? [String: Any] {

            // OpenCNAM results
            if let opencnam = results["telo_opencnam"] as? [String: Any],
               let result = opencnam["result"] as? [String: Any],
               let name = result["name"] as? String {
                additionalInfo["OpenCNAM Name"] = name
                if callerName == nil {
                    callerName = name
                }
            }

            // Trestle results
            if let trestle = results["trestle_reverse_phone"] as? [String: Any],
               let result = trestle["result"] as? [String: Any] {
                if let name = result["name"] as? String {
                    additionalInfo["Trestle Name"] = name
                    if callerName == nil {
                        callerName = name
                    }
                }
                if let address = result["address"] as? String {
                    additionalInfo["Address"] = address
                }
                if let city = result["city"] as? String,
                   let state = result["state"] as? String {
                    additionalInfo["Location"] = "\(city), \(state)"
                }
            }
        }

        return LookupResult(
            phoneNumber: phoneNumber,
            callerName: callerName,
            carrierName: carrierName,
            lineType: lineType,
            countryCode: countryCode,
            additionalInfo: additionalInfo
        )
    }

    // Convert to format suitable for Call Directory
    func toCallDirectoryEntry() -> (phoneNumber: Int64, label: String)? {
        // Remove '+' and convert to Int64
        let cleanNumber = phoneNumber.replacingOccurrences(of: "+", with: "")
        guard let number = Int64(cleanNumber) else { return nil }

        let label = callerName ?? carrierName ?? "Unknown"
        return (phoneNumber: number, label: label)
    }
}
