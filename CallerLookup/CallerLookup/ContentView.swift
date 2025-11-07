//
//  ContentView.swift
//  CallerLookup
//
//  Main view for the CallerLookup app
//

import SwiftUI
import CallKit

struct ContentView: View {
    @EnvironmentObject var twilioService: TwilioService
    @State private var phoneNumber = ""
    @State private var lookupResult: LookupResult?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSettings = false
    @State private var showHistory = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Caller Lookup")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Identify unknown callers")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // Configuration status
                if !twilioService.isConfigured {
                    VStack(spacing: 12) {
                        Label("Configuration Required", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.headline)

                        Button("Configure Twilio Credentials") {
                            showSettings = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Phone number input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.headline)

                    HStack {
                        TextField("e.g., +12223334444", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disabled(isLoading)

                        if !phoneNumber.isEmpty {
                            Button(action: { phoneNumber = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Text("Include country code (e.g., +1 for US)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // Lookup button
                Button(action: performLookup) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                        Text(isLoading ? "Looking up..." : "Lookup Number")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(twilioService.isConfigured && !phoneNumber.isEmpty ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!twilioService.isConfigured || phoneNumber.isEmpty || isLoading)
                .padding(.horizontal)

                // Error message
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                // Results
                if let result = lookupResult {
                    ScrollView {
                        LookupResultView(result: result)
                            .padding()
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                Spacer()

                // Quick actions
                HStack(spacing: 20) {
                    Button(action: { showHistory = true }) {
                        VStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title2)
                            Text("History")
                                .font(.caption)
                        }
                    }

                    Button(action: refreshCallDirectory) {
                        VStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                            Text("Refresh")
                                .font(.caption)
                        }
                    }

                    Button(action: { showSettings = true }) {
                        VStack {
                            Image(systemName: "gear")
                                .font(.title2)
                            Text("Settings")
                                .font(.caption)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showHistory) {
                LookupHistoryView()
            }
        }
    }

    private func performLookup() {
        errorMessage = nil
        lookupResult = nil
        isLoading = true

        Task {
            do {
                let result = try await twilioService.lookupPhoneNumber(phoneNumber)
                await MainActor.run {
                    self.lookupResult = result
                    self.isLoading = false

                    // Save to history
                    twilioService.addToHistory(result)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func refreshCallDirectory() {
        CallDirectoryManager.shared.reloadExtension()
    }
}

struct LookupResultView: View {
    let result: LookupResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Results")
                .font(.title2)
                .fontWeight(.bold)

            if let callerName = result.callerName {
                InfoRow(label: "Caller Name", value: callerName, icon: "person.fill")
            }

            InfoRow(label: "Phone Number", value: result.phoneNumber, icon: "phone.fill")

            if let carrier = result.carrierName {
                InfoRow(label: "Carrier", value: carrier, icon: "antenna.radiowaves.left.and.right")
            }

            if let lineType = result.lineType {
                InfoRow(label: "Line Type", value: lineType, icon: "phone.connection")
            }

            if let country = result.countryCode {
                InfoRow(label: "Country", value: country, icon: "flag.fill")
            }

            // Additional info from add-ons
            if !result.additionalInfo.isEmpty {
                Divider()
                    .padding(.vertical, 8)

                Text("Additional Information")
                    .font(.headline)

                ForEach(result.additionalInfo.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    InfoRow(label: key, value: value, icon: "info.circle")
                }
            }

            // Timestamp
            Text("Looked up: \(result.timestamp, style: .relative) ago")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TwilioService.shared)
    }
}
