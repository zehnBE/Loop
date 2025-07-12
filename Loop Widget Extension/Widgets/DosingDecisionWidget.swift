//
//  DosingDecisionWidget.swift
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

struct DosingDecisionWidgetEntryView: View {
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

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            // Lock Screen circular widget
            PumpView(entry: entry)
                .frame(maxWidth: .infinity, alignment: .center)
            .widgetBackground()
        default:
            EmptyView()
        }
    }
}

struct DosingDecisionWidget: Widget {
    let kind: String = Bundle.main.hostIdentifier + ".DosingDecisionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatusWidgetTimelineProvider()) { entry in
            DosingDecisionWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Last Dosing Decision")
        .description("See the most recent dosing decision that Loop made.")
        .supportedFamilies([.accessoryCircular])
        .contentMarginsDisabledIfAvailable()
    }
}
