//
//  ActiveInsulinWidget.swift
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

struct ActiveInsulinWidgetEntryView: View {
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

    var iobNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()

        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2

        return formatter
    }()

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            // Lock Screen circular widget
            VStack {

                Text("Active Insulin")
                    .font(.footnote)
                    .foregroundColor(entry.contextIsStale ? .staleGray : .secondary)

                if let activeInsulin = entry.activeInsulin, let insulinString = iobNumberFormatter.string(from: activeInsulin) {
                    (Text("\(insulinString) ")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                    + Text(HKUnit.internationalUnit().shortLocalizedUnitString()))
                        .fixedSize()
                }
            }
            .widgetBackground()
        default:
            EmptyView()
        }
    }
}

struct ActiveInsulinWidget: Widget {
    let kind: String = "ActiveInsulinWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatusWidgetTimelineProvider()) { entry in
            ActiveInsulinWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Active Insulin")
        .description("See the amount of active insulin being tracked by Loop.")
        .supportedFamilies([.accessoryCircular])
        .contentMarginsDisabledIfAvailable()
    }
}
