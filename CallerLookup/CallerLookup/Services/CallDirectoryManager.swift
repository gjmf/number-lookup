//
//  CallDirectoryManager.swift
//  CallerLookup
//
//  Manager for Call Directory Extension
//

import Foundation
import CallKit

class CallDirectoryManager {
    static let shared = CallDirectoryManager()

    private init() {}

    func requestAccess(completion: @escaping (Bool) -> Void) {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(
            withIdentifier: "com.callerlookup.CallerLookupExtension"
        ) { status, error in
            if let error = error {
                print("Error getting extension status: \(error)")
                completion(false)
                return
            }

            switch status {
            case .enabled:
                completion(true)
            case .disabled, .unknown:
                // Request access by trying to reload
                self.reloadExtension()
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }

    func reloadExtension() {
        CXCallDirectoryManager.sharedInstance.reloadExtension(
            withIdentifier: "com.callerlookup.CallerLookupExtension"
        ) { error in
            if let error = error {
                print("Error reloading extension: \(error)")
            } else {
                print("Extension reloaded successfully")
            }
        }
    }

    func getEnabledStatus(completion: @escaping (CXCallDirectoryEnabledStatus) -> Void) {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(
            withIdentifier: "com.callerlookup.CallerLookupExtension"
        ) { status, error in
            if let error = error {
                print("Error getting extension status: \(error)")
                completion(.unknown)
                return
            }
            completion(status)
        }
    }
}
