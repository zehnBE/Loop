//
//  ActiveCarbohydratesWidget.swift
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
import HealthKit

struct ActiveCarbohydratesWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    var entry: StatusWidgetTimelimeEntry

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

    var carbFormatter: NumberFormatter = {
        let formatter = NumberFormatter()

        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0

        return formatter
    }()

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            // Lock Screen circular widget
            VStack {

                Text("Active Carbs")
                    .font(.footnote)
                    .foregroundColor(entry.contextIsStale ? .staleGray : .secondary)

                if let activeCarbs = entry.activeCarbs, let carbsString = carbFormatter.string(from: activeCarbs) {
                    (Text("\(carbsString) ")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                    + Text(HKUnit.gram().shortLocalizedUnitString()))
                        .fixedSize()
                }
            }
            .widgetBackground()
        default:
            EmptyView()
        }
    }
}

struct ActiveCarbohydratesWidget: Widget {
    let kind: String = Bundle.main.hostIdentifier + ".ActiveCarbohydratesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatusWidgetTimelineProvider()) { entry in
            ActiveCarbohydratesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Active Carbohydrates")
        .description("See the amount of active carbohydrates being tracked by Loop.")
        .supportedFamilies([.accessoryCircular])
        .contentMarginsDisabledIfAvailable()
    }
}
