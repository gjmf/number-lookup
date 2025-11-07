//
//  CallDirectoryHandler.swift
//  CallerLookupExtension
//
//  Call Directory Extension for identifying incoming calls
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        // Load saved lookup results from shared UserDefaults
        let results = loadLookupResults()

        // Convert results to call directory entries
        var entries: [(phoneNumber: Int64, label: String)] = []

        for result in results {
            if let entry = result.toCallDirectoryEntry() {
                entries.append(entry)
            }
        }

        // Sort by phone number (required by CallKit)
        entries.sort { $0.phoneNumber < $1.phoneNumber }

        // Add identification entries
        do {
            for entry in entries {
                try context.addIdentificationEntry(
                    withNextSequentialPhoneNumber: CXCallDirectoryPhoneNumber(entry.phoneNumber),
                    label: entry.label
                )
            }

            context.completeRequest()
        } catch {
            print("Error adding identification entries: \(error)")
            context.completeRequest(with: error)
        }
    }

    private func loadLookupResults() -> [LookupResult] {
        guard let groupDefaults = UserDefaults(suiteName: "group.com.callerlookup.shared"),
              let data = groupDefaults.data(forKey: "extensionResults"),
              let results = try? JSONDecoder().decode([LookupResult].self, from: data) else {
            return []
        }

        return results
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        print("Call Directory Extension request failed: \(error)")
    }
}

// Include the LookupResult model for the extension
// This is a duplicate to keep the extension independent

struct LookupResult: Codable {
    let phoneNumber: String
    let callerName: String?
    let carrierName: String?
    let lineType: String?
    let countryCode: String?
    let additionalInfo: [String: String]
    let timestamp: Date

    func toCallDirectoryEntry() -> (phoneNumber: Int64, label: String)? {
        let cleanNumber = phoneNumber.replacingOccurrences(of: "+", with: "")
        guard let number = Int64(cleanNumber) else { return nil }

        let label = callerName ?? carrierName ?? "Unknown"
        return (phoneNumber: number, label: label)
    }
}
