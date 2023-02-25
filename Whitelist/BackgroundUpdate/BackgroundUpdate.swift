//
//  BackgroundUpdate.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-23.
//

// not stolen from cowabunga :trollface:

import Foundation
import SwiftUI
import notify
import SystemConfiguration
import os.log

class BackgroundFileUpdaterController: ObservableObject {
    static let shared = BackgroundFileUpdaterController()
    public var time = 120.0
    @Published var enabled: Bool = UserDefaults.standard.bool(forKey: "BackgroundApply")
    func setup() {
        if self.enabled {
            BackgroundFileUpdaterController.shared.updateFiles()
        }
        Timer.scheduledTimer(withTimeInterval: time, repeats: true) { timer in
            if self.enabled {
                BackgroundFileUpdaterController.shared.updateFiles()
            }
        }
    }
    func updateFiles() {
        os_log(.debug, "BG: Updating!")
        if UserDefaults.standard.bool(forKey: "BannedEnabled") == true {
            os_log(.debug, "BG: Overwriting Banned Apps!")
            overwriteBannedApps()
        }
        if UserDefaults.standard.bool(forKey: "CdEnabled") == true {
            os_log(.debug, "BG: Overwriting CDHashes!")
            overwriteCdHashes()
        }
        os_log(.debug, "BG: Overwriting Blacklist!")
        overwriteBlacklist()
    }
}
