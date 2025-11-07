//
//  CallerLookupApp.swift
//  CallerLookup
//
//  An iOS app for identifying unknown callers using Twilio Lookup API
//

import SwiftUI

@main
struct CallerLookupApp: App {
    @StateObject private var twilioService = TwilioService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(twilioService)
        }
    }
}
