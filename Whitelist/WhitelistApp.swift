//
//  WhitelistApp.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import SwiftUI

@main
struct WhitelistApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if #available(iOS 16.2, *) {
#if targetEnvironment(simulator)
#else
                        // I'm sorry 16.2 dev beta 1 users, you are a vast minority.
                        UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported.", withButton: false)
#endif
                    } else {
                        do {
                            // TrollStore method
                            try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches"), includingPropertiesForKeys: nil)
                        } catch {
                            // MDC method
                            // grant r/w access
                            if #available(iOS 15, *) {
                                grant_full_disk_access() { error in
                                    if (error != nil) {
                                        UIApplication.shared.alert(title: "Access Error", body: "Error: \(String(describing: error?.localizedDescription))\nPlease close the app and retry.", withButton: false)
                                    }
                                }
                            } else {
                                UIApplication.shared.alert(title: "Exploit Not Supported", body: "Please install via TrollStore")
                            }
                        }
                    }
                }
        }
    }
}
