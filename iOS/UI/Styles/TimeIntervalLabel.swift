//
//  TimeIntervalLabel.swift
//  Jotts
//
//  Created by Hank Brekke on 12/5/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI
import Combine

enum TimeIntervalTextType {
    case before
    case during
    case after
}

fileprivate class TimeIntervalTrigger: ObservableObject {
    @Published var timeInterval: TimeInterval

    private let destination: Date
    private let origin: Date
    private var sink: AnyCancellable?

    init(destination: Date, origin: Date = Date()) {
        self.destination = destination
        self.origin = origin

        self.timeInterval = self.destination.timeIntervalSince(self.origin)

        DispatchQueue.main.async {
            self.sink = Timer.publish(every: 1, on: .current, in: .default)
                .autoconnect()
                .sink { [unowned self] _ in
                    self.timeInterval = self.destination.timeIntervalSince(self.origin)
                }
        }
    }
}

struct TimeIntervalText<IntervalView: View>: View {
    private let render: ((TimeInterval) -> IntervalView)
    @ObservedObject private var trigger: TimeIntervalTrigger

    init(
        destination: Date,
        origin: Date = Date(),
        @ViewBuilder render: @escaping ((TimeInterval) -> IntervalView)
    ) {
        self.render = render

        self.trigger = TimeIntervalTrigger(destination: destination, origin: origin)
    }

    var body: some View {
        self.render(self.trigger.timeInterval)
    }
}

struct DailySessionText: View {
    let session: DailySession

    @ObservedObject private var trigger: TimeIntervalTrigger
    private let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        return formatter
    }()

    init(session: DailySession) {
        self.session = session

        self.trigger = TimeIntervalTrigger(destination: self.session.startDate())
    }

    var body: some View {
        if self.session.schedule?.isFault ?? self.session.session!.isFault {
            // Catch any `isFault` documents (actively being deleted) to avoid crash
            // when determining `startDate()/endDate()` value.
            return AnyView(Text("..."))
        }

        let startDate = self.session.startDate()
        let endDate = self.session.endDate()

        if startDate.timeIntervalSinceNow > 0 {
            return AnyView(TimeIntervalText(destination: startDate) { interval in
                Text("In \(self.formatter.string(from: interval)!)", comment: "Time interval to start of event")
            })
        } else if endDate.timeIntervalSinceNow > 0 {
            return AnyView(TimeIntervalText(destination: endDate) { interval in
                Text("\(self.formatter.string(from: interval)!) remaining", comment: "Time interval to end of event")
            })
        }

        return AnyView(TimeIntervalText(destination: endDate) { interval in
            Text("\(self.formatter.string(from: -interval)!) ago", comment: "Time interval since end of event")
        })
    }
}
