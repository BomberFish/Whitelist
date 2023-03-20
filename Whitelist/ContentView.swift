//
//  ContentView.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import SwiftUI
import os.log

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
    @ObservedObject var backgroundController = BackgroundFileUpdaterController.shared
    @State private var bgUpdateInterval: Double = UserDefaults.standard.double(forKey: "BackgroundUpdateInterval")
    @State var runInBackground: Bool = UserDefaults.standard.bool(forKey: "BackgroundApply")

    @State var bgUpdateIntervalDisplayTitles: [Double: String] = [
        120.0: "Frequent",
        600.0: "Power Saver"
    ]
    
    @State var bgUpdateIntervalIcons: [Double: String] = [
        120.0: "bolt.badge.clock",
        600.0: "leaf"
    ]
    
    let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(
                        action: {
                            os_log(.debug, "FG: Applying!")
                            Haptic.shared.play(.heavy)
                            inProgress = true
                            
                            if banned {
                                banned_success = overwriteBannedApps()
                            }
                            if cdHash {
                                hash_success = overwriteCdHashes()
                            } else {
                                banned_success = false
                                hash_success = false
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
                                os_log(.debug, "FG: Success! See UI for details.")
                            } else {
                                UIApplication.shared.alert(title: "Error", body: "An error occurred while writing to the file.", withButton: true)
                                os_log(.debug, "FG: Error! See UI for details.")
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
                            UIApplication.shared.confirmAlert(title: "Background Update \(newWord)", body: "The app will close. Re-open Whitelist to apply the change.", onOK: {
                                exit(0)
                            }, noCancel: true)
                            //BackgroundFileUpdaterController.shared.enabled = new
                        }
                    // background run frequency
                    HStack {
                        Label("Update Frequency", systemImage: "clock.arrow.circlepath")
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Button( action: {
                            // create and configure alert controller
                            let alert = UIAlertController(title: "Update Frequency", message: "Choose an update option", preferredStyle: .actionSheet)
                            
                            // create the actions
                            for (t, title) in bgUpdateIntervalDisplayTitles {
                                let newAction = UIAlertAction(title: NSLocalizedString(title, comment: "The option title for background frequency"), style: .default) { (action) in
                                    // apply the type
                                    bgUpdateInterval = t
                                    // set the default
                                    UserDefaults.standard.set(t, forKey: "BackgroundUpdateInterval")
                                    // update the timer
                                    backgroundController.time = bgUpdateInterval
                                }
                                if bgUpdateInterval == t {
                                    // add a check mark
                                    newAction.setValue(true, forKey: "checked")
                                }
                                alert.addAction(newAction)
                            }
                            
                            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (action) in
                                // cancels the action
                            }
                            
                            // add the actions
                            alert.addAction(cancelAction)
                            
                            let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                            // present popover for iPads
                            alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                            alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                            
                            // present the alert
                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                        },label:{
                            Label(bgUpdateIntervalDisplayTitles[bgUpdateInterval] ?? "Error", systemImage: bgUpdateIntervalIcons[bgUpdateInterval] ?? "")
                            
                        })
                        .foregroundColor(.accentColor)
                        .padding(.leading, 10)
                    }
                    
                    
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
                    .toolbar {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Label("", systemImage: "gear")
                        }
                    }
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
