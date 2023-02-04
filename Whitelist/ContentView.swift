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
    @State var cdHash = true
    @State var inProgress = false
    @State var message = ""
    let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Overwrite Blacklist", isOn: $blacklist)
                        .toggleStyle(.switch)
                        .disabled(true)
                        .tint(.accentColor)
                        .disabled(inProgress)
                    Toggle("Overwrite Banned Apps", isOn: $banned)
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        .disabled(inProgress)
                    Toggle("Overwrite CDHashes", isOn: $cdHash)
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        .disabled(inProgress)
                } header: {
                    Label("Options", systemImage: "gear")
                }
                Section {
                    Button(
                        action: {
                            Haptic.shared.play(.heavy)
                            inProgress = true
                            let success = overwriteBlacklists(banned: banned, cdhash: cdHash)
                            if success == true {
                                UIApplication.shared.alert(title: "Success", body: "Successfully removed blacklist.", withButton: true)
                                Haptic.shared.notify(.success)
                            } else {
                                UIApplication.shared.alert(title: "Error", body: "An error occurred while writing to the file.", withButton: true)
                                Haptic.shared.notify(.error)
                            }
                            inProgress = false
                        },
                        label: { Label("Apply", systemImage: "app.badge.checkmark") }
                    )
                    // Thanks ChatGPT!
                    .disabled(!blacklist && !banned && !cdHash || inProgress)
                } header: {
                    Label("Make It So, Number One", systemImage: "arrow.right.circle")
                }
                
                Section {
                    NavigationLink(destination: ContentsView()) {
                        Text("View contents of blacklist files")
                    }
                } header : {
                    Label("Advanced", systemImage: "wrench.and.screwdriver")
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
