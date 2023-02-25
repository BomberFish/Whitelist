//
//  ContentsView.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import SwiftUI

struct FileContentsView: View {
    @State var blacklistContent = readFile(path: "/private/var/db/MobileIdentityData/Rejections.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
    @State var bannedAppsContent = readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
    @State var cdHashesContent = readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
    
    @State var refreshing = false
    
    var body: some View {
        List {
            Section {
                if refreshing {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    Text(blacklistContent)
                        .font(.system(.subheadline, design: .monospaced))
                }
                
            } header: {
                Label("Blacklist", systemImage: "xmark.seal")
            }
            
            Section {
                if refreshing {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    Text(bannedAppsContent)
                        .font(.system(.subheadline, design: .monospaced))
                }
            } header: {
                Label("Banned Apps", systemImage: "xmark.app")
            }

            Section {
                if refreshing {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    Text(cdHashesContent)
                        .font(.system(.subheadline, design: .monospaced))
                }
            } header: {
                Label("CD Hashes", systemImage: "number.square")
            }

        }
        .refreshable {
            do {
                Haptic.shared.play(.rigid)
                print("Updating files!")
                refreshing = true
                blacklistContent = ""
                bannedAppsContent = ""
                cdHashesContent = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    blacklistContent = readFile(path: "/private/var/db/MobileIdentityData/Rejections.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
                    bannedAppsContent = readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
                    cdHashesContent = readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") ?? "ERROR: Could not read from file! Are you running in the simulator or not unsandboxed?"
                    print("Files updated!")
                    refreshing = false
                    Haptic.shared.play(.light)
                }
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

struct FileContentsView_Previews: PreviewProvider {
    static var previews: some View {
        FileContentsView()
    }
}
