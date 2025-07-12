//
//  EventualBGWidget.swift
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

struct EventualBGWidgetEntryView: View {
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
            EventualGlucoseView(entry: entry)
                .frame(maxWidth: .infinity, alignment: .center)
            .widgetBackground()
        default:
            EmptyView()
        }
    }
}

struct EventualBGWidget: Widget {
    let kind: String = "EventualBGWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatusWidgetTimelineProvider()) { entry in
            EventualBGWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Eventual Glucose")
        .description("The end of Loop's forecast for your eventual glucose level.")
        .supportedFamilies([.accessoryCircular])
        .contentMarginsDisabledIfAvailable()
    }
}
