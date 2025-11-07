//
//  LookupHistoryView.swift
//  CallerLookup
//
//  View for displaying lookup history
//

import SwiftUI

struct LookupHistoryView: View {
    @EnvironmentObject var twilioService: TwilioService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Group {
                if twilioService.lookupHistory.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)

                        Text("No Lookup History")
                            .font(.title2)
                            .fontWeight(.medium)

                        Text("Your phone number lookups will appear here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(twilioService.lookupHistory.reversed()) { result in
                            HistoryRow(result: result)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Lookup History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !twilioService.lookupHistory.isEmpty {
                        EditButton()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let reversedHistory = twilioService.lookupHistory.reversed()
        let indices = offsets.map { reversedHistory.count - 1 - $0 }

        for index in indices.sorted(by: >) {
            twilioService.removeFromHistory(at: index)
        }
    }
}

struct HistoryRow: View {
    let result: LookupResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let callerName = result.callerName {
                        Text(callerName)
                            .font(.headline)
                    } else {
                        Text("Unknown Caller")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }

                    Text(result.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if let carrier = result.carrierName {
                        Text(carrier)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(result.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            if let lineType = result.lineType {
                Label(lineType, systemImage: "phone.connection")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct LookupHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        LookupHistoryView()
            .environmentObject(TwilioService.shared)
    }
}
