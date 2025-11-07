//
//  SettingsView.swift
//  CallerLookup
//
//  Settings and configuration view
//

import SwiftUI
import CallKit

struct SettingsView: View {
    @EnvironmentObject var twilioService: TwilioService
    @Environment(\.dismiss) var dismiss

    @State private var accountSID: String = ""
    @State private var authToken: String = ""
    @State private var showPassword = false
    @State private var saveMessage: String?
    @State private var showExtensionInfo = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Twilio Credentials")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account SID")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("AC...", text: $accountSID)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Auth Token")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.blue)
                            }
                        }

                        if showPassword {
                            TextField("Your auth token", text: $authToken)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            SecureField("Your auth token", text: $authToken)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }

                    Button(action: saveCredentials) {
                        HStack {
                            Spacer()
                            Text("Save Credentials")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    if let message = saveMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Section(header: Text("How to Get Credentials")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Go to console.twilio.com")
                        Text("2. Sign in or create a free account")
                        Text("3. Find your Account SID and Auth Token on the dashboard")
                        Text("4. Copy and paste them above")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    Link("Open Twilio Console", destination: URL(string: "https://console.twilio.com")!)
                }

                Section(header: Text("Call Directory Extension")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: twilioService.isConfigured ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(twilioService.isConfigured ? .green : .red)

                            Text(twilioService.isConfigured ? "Configured" : "Not Configured")
                                .fontWeight(.medium)
                        }

                        Text("The Call Directory Extension allows iOS to automatically identify incoming calls.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button(action: enableCallDirectory) {
                            HStack {
                                Image(systemName: "phone.badge.plus")
                                Text("Enable Call Identification")
                            }
                        }
                        .buttonStyle(.bordered)

                        Button(action: { showExtensionInfo = true }) {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("Setup Instructions")
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Lookup History")
                        Spacer()
                        Text("\(twilioService.lookupHistory.count) entries")
                            .foregroundColor(.secondary)
                    }

                    Button(action: clearHistory) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear History")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showExtensionInfo) {
                ExtensionInfoView()
            }
            .onAppear {
                loadCredentials()
            }
        }
    }

    private func loadCredentials() {
        if let sid = twilioService.accountSID {
            accountSID = sid
        }
        if let token = twilioService.authToken {
            authToken = token
        }
    }

    private func saveCredentials() {
        twilioService.configure(accountSID: accountSID, authToken: authToken)
        saveMessage = "Credentials saved successfully!"

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            saveMessage = nil
        }
    }

    private func enableCallDirectory() {
        CallDirectoryManager.shared.requestAccess { granted in
            if granted {
                CallDirectoryManager.shared.reloadExtension()
            }
        }
    }

    private func clearHistory() {
        twilioService.clearHistory()
    }
}

struct ExtensionInfoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to Enable Call Identification")
                        .font(.title2)
                        .fontWeight(.bold)

                    VStack(alignment: .leading, spacing: 16) {
                        StepView(
                            number: 1,
                            title: "Open Settings App",
                            description: "Go to your iPhone's Settings app"
                        )

                        StepView(
                            number: 2,
                            title: "Navigate to Phone Settings",
                            description: "Scroll down and tap on 'Phone'"
                        )

                        StepView(
                            number: 3,
                            title: "Call Blocking & Identification",
                            description: "Tap 'Call Blocking & Identification'"
                        )

                        StepView(
                            number: 4,
                            title: "Enable CallerLookup",
                            description: "Toggle on 'CallerLookup' to enable call identification"
                        )

                        StepView(
                            number: 5,
                            title: "Return to App",
                            description: "Come back to this app and tap 'Enable Call Identification' in Settings"
                        )
                    }

                    Divider()
                        .padding(.vertical)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Important Notes")
                            .font(.headline)

                        Label("The extension identifies calls automatically when enabled", systemImage: "checkmark.circle")
                            .font(.caption)

                        Label("Your Twilio account will be charged for lookups", systemImage: "dollarsign.circle")
                            .font(.caption)

                        Label("Call data is processed locally on your device", systemImage: "lock.shield")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Setup Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StepView: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)

                Text("\(number)")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(TwilioService.shared)
    }
}
