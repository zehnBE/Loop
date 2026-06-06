//
//  DeeplinkManager.swift
//  Loop
//
//  Created by Cameron Ingham on 6/26/23.
//  Copyright © 2023 LoopKit Authors. All rights reserved.
//

import UIKit
import LoopKit
import HealthKit

enum Deeplink: String, CaseIterable {
    case carbEntry = "carb-entry"
    case bolus = "manual-bolus"
    case preMeal = "pre-meal-preset"
    case customPresets = "custom-presets"
    
    init?(url: URL?) {
        guard let url, let host = url.host, let deeplink = Deeplink.allCases.first(where: { $0.rawValue == host }) else {
            return nil
        }
        
        self = deeplink
    }
}

class DeeplinkManager {
    
    private weak var rootViewController: UIViewController?
    
    init(rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
    }
    
    func handle(_ url: URL) -> Bool {
        // CarbCam URL scheme - dispatched separately from standard Loop deeplinks.
        if url.scheme == "carbcam-loop" {
            return handleCarbCamURL(url)
        }

        guard let rootViewController = rootViewController as? RootNavigationController, let deeplink = Deeplink(url: url) else {
            return false
        }
        
        rootViewController.navigate(to: deeplink)
        return true
    }
    
    /// Handles `carbcam-loop://carbs?value=N&notes=...&source=...` from 10BE CarbCam.
    private func handleCarbCamURL(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.host == "carbs",
              let items = components.queryItems,
              let valueStr = items.first(where: { $0.name == "value" })?.value,
              let value = Int(valueStr),
              value >= 1, value <= 80
        else { return false }

        let notes = (items.first(where: { $0.name == "notes" })?.value ?? "")
            .prefix(200)
            .description

        let entry = NewCarbEntry(
            quantity: HKQuantity(unit: .gram(), doubleValue: Double(value)),
            startDate: Date(),
            foodType: notes.isEmpty ? nil : notes,
            absorptionTime: nil
        )

        let activity = NSUserActivity.forNewCarbEntry()
        activity.update(from: entry)

        rootViewController?.restoreUserActivityState(activity)
        return true
    }

    func handle(_ deeplink: Deeplink) -> Bool {
        guard let rootViewController = rootViewController as? RootNavigationController else {
            return false
        }
        
        rootViewController.navigate(to: deeplink)
        return true
    }
}
