//
//  ContentsView.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

// FIXME: This might be hard to distinguish from ContentView.

import SwiftUI

struct ContentsView: View {
    @State var blacklistContent = readFile(path: "/private/var/db/MobileIdentityData/Rejections.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
    @State var bannedAppsContent = readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
    @State var cdHashesContent = readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
    
    var body: some View {
        List {
            Section {
                Text(blacklistContent)
                    .font(.system(.subheadline, design: .monospaced))
            } header: {
                Label("Blacklist", systemImage: "xmark.seal")
            }
            
            Section {
                Text(bannedAppsContent)
                    .font(.system(.subheadline, design: .monospaced))
            } header: {
                Label("Banned Apps", systemImage: "xmark.app")
            }

            Section {
                Text(cdHashesContent)
                    .font(.system(.subheadline, design: .monospaced))
            } header: {
                Label("CD Hashes", systemImage: "number.square")
            }

        }
        .refreshable {
            do {
                Haptic.shared.play(.rigid)
                print("Updating files!")
                blacklistContent = ""
                bannedAppsContent = ""
                cdHashesContent = ""
                blacklistContent = readFile(path: "/private/var/db/MobileIdentityData/Rejections.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
                bannedAppsContent = readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
                cdHashesContent = readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
                print("Files updated!")
            }
        }
            .navigationTitle("Blacklist File Contents")
            .onAppear {
                print("Reading files!")
                blacklistContent = readFile(path: "/private/var/db/MobileIdentityData/Rejections.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
                bannedAppsContent = readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
                cdHashesContent = readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?" 
            }
    }
        
}

struct ContentsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentsView()
    }
}
