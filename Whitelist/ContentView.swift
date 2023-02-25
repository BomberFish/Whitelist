//
//  ContentView.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import SwiftUI

struct ContentView: View {
    @State var blacklist = true
    @State var banned: Bool = UserDefaults.standard.bool(forKey: "BannedEnabled")
    @State var cdHash: Bool = UserDefaults.standard.bool(forKey: "CdEnabled")
    @State var inProgress = false
    @State var message = ""
    @State var banned_success = false
    @State var blacklist_success = false
    @State var hash_success = false
    @State var success = false
    @State var success_message = ""
    @State var runInBackground: Bool = UserDefaults.standard.bool(forKey: "BackgroundApply")
    
    let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(
                        action: {
                            Haptic.shared.play(.heavy)
                            inProgress = true
                            
                            if banned {
                                banned_success = overwriteBannedApps()
                            }
                            if cdHash {
                                hash_success = overwriteCdHashes()
                            }
                            success = overwriteBlacklist()
                            
                            // FIXME: Bad.
                            if banned_success && hash_success {
                                success_message = "Successfully removed: Blacklist, Banned Apps, CDHashes\nDidn't overwrite: none"
                            } else if !banned_success && hash_success {
                                success_message = "Successfully removed: Blacklist, CDHashes\nDidn't overwrite: Banned Apps"
                            } else if banned_success && !hash_success {
                                success_message = "Successfully removed: Blacklist, Banned Apps\nDidn't overwrite: CDHashes"
                            } else {
                                success_message = "Successfully removed: Blacklist\nDidn't overwrite: Banned Apps, CDHashes"
                            }
                            
                            if success {
                                UIApplication.shared.alert(title: "Success", body: success_message, withButton: true)
                                inProgress = false
                                Haptic.shared.notify(.success)
                            } else {
                                UIApplication.shared.alert(title: "Error", body: "An error occurred while writing to the file.", withButton: true)
                                inProgress = false
                                Haptic.shared.notify(.error)
                            }
                            inProgress = false
                        },
                        label: { Label("Apply", systemImage: "app.badge.checkmark") }
                    )
                } header: {
                    Label("Make It So, Number One", systemImage: "arrow.right.circle")
                }
                Section {
                    Toggle(isOn: $blacklist, label:{Label("Overwrite Blacklist", systemImage: "xmark.seal")})
                        .toggleStyle(.switch)
                        .disabled(true)
                        .tint(.accentColor)
                        .disabled(inProgress)
                    Toggle(isOn: $banned, label:{Label("Overwrite Banned Apps", systemImage: "xmark.app")})
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        .disabled(inProgress)
                        .onChange(of: banned) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "BannedEnabled")
                        }
                    Toggle(isOn: $cdHash, label:{Label("Overwrite CDHashes", systemImage: "number.square")})
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        .disabled(inProgress)
                        .onChange(of: cdHash) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "CdEnabled")
                        }
                } header: {
                    Label("Options", systemImage: "gear")
                }
                Section{
                    Toggle(isOn: $runInBackground, label:{Label("Run in background", systemImage: "app.dashed")})
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        .onChange(of: runInBackground) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "BackgroundApply")
                            var newWord: String = "Enabled"
                            if new == false {
                                newWord = "Disabled"
                                ApplicationMonitor.shared.stop()
                            }
                            UIApplication.shared.confirmAlert(title: "Background Update \(newWord)", body: "The app will restart to apply the change.", onOK: {
                                exit(0)
                            }, noCancel: true)
                            //BackgroundFileUpdaterController.shared.enabled = new
                        }
                    Label("Update Frequency (eta son)", systemImage: "clock.arrow.circlepath")
                    
                    
                } header: {
                    Label("Background Update", systemImage: "location.fill")
                }
                
                Section {
                    NavigationLink(destination: FileContentsView()) {
                        Label("View contents of blacklist files", systemImage: "doc.text")
                    }
                } header : {
                    Label("Advanced", systemImage: "wrench.and.screwdriver")
                }
                
                Section(header: Text("Whitelist " + appVersion + "\nMade with ❤️ by BomberFish")) {}.textCase(nil)
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
