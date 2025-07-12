//
//  StatusWidgetTimelimeEntry.swift
//  Loop Widget Extension
//
//  Created by Cameron Ingham on 6/26/23.
//  Copyright © 2023 LoopKit Authors. All rights reserved.
//

import HealthKit
import LoopCore
import LoopKit
import WidgetKit
import LoopAlgorithm


struct StatusWidgetTimelimeEntry: TimelineEntry {
    var date: Date
    
    let contextUpdatedAt: Date
    
    let lastLoopCompleted: Date?
    let mostRecentGlucoseDataDate: Date?
    let mostRecentPumpDataDate: Date?
    let closeLoop: Bool
    
    let currentGlucose: GlucoseValue?
    let glucoseFetchedAt: Date?
    let delta: HKQuantity?
    let unit: HKUnit?
    let sensor: GlucoseDisplayableContext?

    let pumpHighlight: DeviceStatusHighlightContext?
    let netBasal: NetBasalContext?
    
    let eventualGlucose: GlucoseContext?
    
    let preMealPresetAllowed: Bool
    let preMealPresetActive: Bool
    let customPresetActive: Bool
    let activeInsulin: Double?
    let activeCarbs: Double?

    // Whether context data is old
    var contextIsStale: Bool {
        return (date - contextUpdatedAt) >= StatusWidgetTimelineProvider.stalenessAge
    }

    var glucoseStatusIsStale: Bool {
        guard let glucoseFetchedAt = glucoseFetchedAt else {
            return true
        }
        let glucoseStatusAge = date - glucoseFetchedAt
        return glucoseStatusAge >= StatusWidgetTimelineProvider.stalenessAge
    }

    var glucoseIsStale: Bool {
        guard let glucoseDate = currentGlucose?.startDate else {
            return true
        }
        let glucoseAge = date - glucoseDate

        return glucoseAge >= LoopAlgorithm.inputDataRecencyInterval
    }

    var formattedLastLoop: String {
        if let lastLoopCompleted {
            return DateFormatter.localizedString(from: lastLoopCompleted, dateStyle: .none, timeStyle: .short)
        } else {
            return "-"
        }
    }

    var formattedDelta: String {
        guard let delta, let unit else { return "-" }
        let deltaValue = delta.doubleValue(for: unit)
        let numberFormatter = NumberFormatter.glucoseFormatter(for: unit)
        let deltaString = (deltaValue < 0 ? "-" : "+") + numberFormatter.string(from: abs(deltaValue))!
        return deltaString + " " + (unit.localizedShortUnitString)
    }

    var glucoseUnit: String {
        guard let unit else { return "" }
        return unit.localizedShortUnitString
    }

    var formattedGlucose: String {
        guard !glucoseIsStale,
              let glucoseQuantity = currentGlucose?.quantity,
              let unit,
              let glucoseString = NumberFormatter.glucoseFormatter(for: unit).string(from: glucoseQuantity.doubleValue(for: unit)) else {
            return "---"
        }
        return glucoseString
    }
}
