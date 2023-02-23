//
//  ApplicationMonitor.swift
//  Clip
//
//  Created by Riley Testut on 6/27/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//
import UIKit
import AVFoundation
import UserNotifications
import Combine

private enum UserNotification: String
{
    case appStoppedRunning = "com.rileytestut.Clip.AppStoppedRunning"
}

private extension CFNotificationName
{
    static let altstoreRequestAppState: CFNotificationName = CFNotificationName("com.altstore.RequestAppState.com.rileytestut.Clip" as CFString)
    static let altstoreAppIsRunning: CFNotificationName = CFNotificationName("com.altstore.AppState.Running.com.rileytestut.Clip" as CFString)
}

private let ReceivedApplicationState: @convention(c) (CFNotificationCenter?, UnsafeMutableRawPointer?, CFNotificationName?, UnsafeRawPointer?, CFDictionary?) -> Void =
{ (center, observer, name, object, userInfo) in
    ApplicationMonitor.shared.receivedApplicationStateRequest()
}

class ApplicationMonitor
{
    static let shared = ApplicationMonitor()
    
    let locationManager = LocationManager()
    
    private(set) var isMonitoring = false
    
    private var backgroundTaskID: UIBackgroundTaskIdentifier?
}

extension ApplicationMonitor
{
    func start()
    {
        guard !self.isMonitoring else { return }
        self.isMonitoring = true
        
        self.cancelApplicationQuitNotification() // Cancel any notifications from a previous launch.
        self.scheduleApplicationQuitNotification()
        
        self.locationManager.start()
        self.registerForNotifications()
    }
    
    func stop() {
        self.cancelApplicationQuitNotification()
    }
}

private extension ApplicationMonitor
{
    func registerForNotifications()
    {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterAddObserver(center, nil, ReceivedApplicationState, CFNotificationName.altstoreRequestAppState.rawValue, nil, .deliverImmediately)
    }
    
    func scheduleApplicationQuitNotification()
    {
        let delay = 5 as TimeInterval
        
        let content = UNMutableNotificationContent()
        content.title = "App Stopped Running"
        content.body = "Tap this notification to continue running Whitelist in the background."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay + 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UserNotification.appStoppedRunning.rawValue, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            // If app is still running at this point, we schedule another notification with same identifier.
            // This prevents the currently scheduled notification from displaying, and starts another countdown timer.
            self.scheduleApplicationQuitNotification()
        }
    }
    
    func cancelApplicationQuitNotification()
    {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [UserNotification.appStoppedRunning.rawValue])
    }
    
    func sendNotification(title: String, message: String)
    {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

private extension ApplicationMonitor
{
    func receivedApplicationStateRequest()
    {
        guard UIApplication.shared.applicationState != .background else { return }
        
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(center!, CFNotificationName(CFNotificationName.altstoreAppIsRunning.rawValue), nil, nil, true)
    }
}
