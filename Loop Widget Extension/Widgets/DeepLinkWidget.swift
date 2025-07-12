//
//  DeepLinkWidget.swift
//  Loop
//
//  Created by Pete Schwamb on 6/12/25.
//  Copyright © 2025 LoopKit Authors. All rights reserved.
//

import SwiftUI
import WidgetKit
import LoopUI
import LoopKit
import LoopKitUI

struct DeepLinkWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    var entry: StatusWidgetTimelimeEntry
    let destination: Deeplink


    var freshness: LoopCompletionFreshness {
        var age: TimeInterval

        if entry.closeLoop {
            let lastLoopCompleted = entry.lastLoopCompleted ?? Date().addingTimeInterval(.minutes(16))
            age = abs(min(0, lastLoopCompleted.timeIntervalSinceNow))
        } else {
            let mostRecentGlucoseDataDate = entry.mostRecentGlucoseDataDate ?? Date().addingTimeInterval(.minutes(16))
            let mostRecentPumpDataDate = entry.mostRecentPumpDataDate ?? Date().addingTimeInterval(.minutes(16))
            age = max(abs(min(0, mostRecentPumpDataDate.timeIntervalSinceNow)), abs(min(0, mostRecentGlucoseDataDate.timeIntervalSinceNow)))
        }

        return LoopCompletionFreshness(age: age)
    }

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            // Lock Screen circular widget
            DeeplinkView(destination: destination)
                .widgetBackground()
        default:
            EmptyView()
        }
    }
}

struct DeepLinkWidget: Widget {
    let destination: Deeplink

    init(destination: Deeplink) {
        self.destination = destination
    }

    var kind: String {
        Bundle.main.hostIdentifier + ".DeepLinkWidget." + destination.rawValue
    }

    init() {
        self.destination = .carbEntry
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatusWidgetTimelineProvider()) { entry in
            DeepLinkWidgetEntryView(entry: entry, destination: destination)
        }
        .configurationDisplayName(destination.widgetTitle)
        .description(destination.widgetDescription)
        .supportedFamilies([.accessoryCircular])
        .contentMarginsDisabledIfAvailable()
    }
}

fileprivate extension Deeplink {
    var widgetTitle: String {
        switch self {
            case .carbEntry:
            return "Carb Entry"
        case .bolus:
            return "Manual Bolus"
        case .preMeal:
            return "Pre-Meal Preset"
        case .customPresets:
            return "Custom Presets"
        }
    }

    var widgetDescription: String {
        switch self {
            case .carbEntry:
            return "Log your carb intake."
        case .bolus:
            return "Manually administer a bolus."
        case .preMeal:
            return "Turn on pre-meal mode."
        case .customPresets:
            return "Enact a Temporary Preset."
        }
    }
}
