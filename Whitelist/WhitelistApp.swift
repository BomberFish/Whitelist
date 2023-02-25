//
//  WhitelistApp.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import SwiftUI
import os.log

var isUnsandboxed = false

@main
struct WhitelistApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if #available(iOS 16.2, *) {
#if targetEnvironment(simulator)
#else
                        // I'm sorry 16.2 dev beta 1 users, you are a vast minority.
                        // TODO: Maybe a sandbox escape can persist through updates? SB extension token is stored in docs so...
                        print("Throwing not supported error (patched)")
                        os_log(.error, "ERROR: Running iOS 16.2, MDC patched!")
                        UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported.", withButton: false)
#endif
                    } else {
                        do {
                            // TrollStore method
                            print("Checking if installed with TrollStore...")
                            try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches"), includingPropertiesForKeys: nil)
                            os_log(.info, "INFO: TrollStore detected!")
                            isUnsandboxed = true
                        } catch {
                            isUnsandboxed = false
                            // MDC method
                            // grant r/w access
                            if #available(iOS 15, *) {
                                print("Trying sandbox escape...")
                                grant_full_disk_access() { error in
                                    if (error != nil) {
                                        print("Unable to escape sandbox! Error: ", String(describing: error?.localizedDescription ?? "unknown?!"))
                                        os_log(.fault, "ERROR: unsandbox failed!!! omg panic!!!!!")
                                        UIApplication.shared.alert(title: "Access Error", body: "Error: \(String(describing: error?.localizedDescription))\nPlease close the app and retry.", withButton: false)
                                        isUnsandboxed = false
                                    }
                                }
                                os_log(.info, "INFO: Probably escaped sandbox.")
                                isUnsandboxed = true
                            } else {
                                print("Throwing not supported error (too old)")
                                os_log(.error, "ERROR: Running below iOS 15, do we really need this check???")
                                UIApplication.shared.alert(title: "Exploit Not Supported", body: "Please install via TrollStore")
                                isUnsandboxed = false
                            }
                        }
                    }
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/BomberFish/Whitelist/releases/latest") {
                        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                            guard let data = data else { return }
                            
                            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                                    UIApplication.shared.confirmAlert(title: "Update available!", body: "A new app update is available, do you want to visit the releases page?", onOK: {
                                        UIApplication.shared.open(URL(string: "https://github.com/BomberFish/Whitelist/releases/latest")!)
                                    }, noCancel: false)
                                }
                            }
                        }
                        task.resume()
                    }
                    
                }
        }
    }
}
