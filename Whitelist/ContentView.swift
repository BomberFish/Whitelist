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
    var body: some View {
        List {
            Section {
                Toggle("Overwrite Blacklist", isOn: $blacklist)
                    .toggleStyle(.switch)
                Toggle("Overwrite Banned Apps", isOn: $banned)
                    .toggleStyle(.switch)
                Toggle("Overwrite CDHashes", isOn: $cdhash)
                    .toggleStyle(.switch)
            }
            Section {
                Button(
                    action:{ OverwriteBlacklists(blacklist: blacklist, banned: banned, cdhash: cdhash)},
                    label: {Label("Apply", systemImage: "app.badge.checkmark")}
                )
                // Thanks ChatGPT!
                .disabled(!blacklist && !banned && !cdhash)
            }
        }
        .navigationTitle("Whitelist")
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
