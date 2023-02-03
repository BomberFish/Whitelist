//
//  ContentView.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import SwiftUI

struct ContentView: View {
    @State var blacklist = true
    @State var banned = true
    @State var cdhash = true
    let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Overwrite Blacklist", isOn: $blacklist)
                        .toggleStyle(.switch)
                        .disabled(true)
                    Toggle("Overwrite Banned Apps", isOn: $banned)
                        .toggleStyle(.switch)
                    Toggle("Overwrite CDHashes", isOn: $cdhash)
                        .toggleStyle(.switch)
                } header: {
                    Text("Options")
                }
                Section {
                    Button(
                        action: { OverwriteBlacklists(banned: banned, cdhash: cdhash) },
                        label: { Label("Apply", systemImage: "app.badge.checkmark") }
                    )
                    // Thanks ChatGPT!
                    .disabled(!blacklist && !banned && !cdhash)
                } header: {
                    Text("Make it so, number one")
                }
                
                Section(header: Text("Whitelist " + appVersion + "\nMade with ❤️ by BomberFish")) {}
            }
            .navigationTitle("Whitelist")
        }
        .navigationTitle("Whitelist")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
