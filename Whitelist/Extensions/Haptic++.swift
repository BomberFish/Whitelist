//
//  Haptic++.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import Foundation
import UIKit

class Haptic {
    static let shared = Haptic()
    
    private init() { }

    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
