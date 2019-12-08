//
//  TimeIntervalLabel.swift
//  Jotts
//
//  Created by Hank Brekke on 12/5/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

enum TimeIntervalTextType {
    case before
    case during
    case after
}

struct TimeIntervalText: View {
    let destination: Date
    let type: TimeIntervalTextType

    let origin: Date = Date()
    let render: ((TimeInterval, TimeIntervalTextType) -> String) = { (interval, type) in
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1

        switch type {
        case .during:
            formatter.includesTimeRemainingPhrase = true

            return "\(formatter.string(from: interval)!)"
        case .before:
            return "In \(formatter.string(from: interval)!)"
        case .after:
            return "\(formatter.string(from: -interval)!) ago"
        }
    }

    @State private var label: String?
    @State private var adjustmentTimer: Timer? = nil

    func buildLabel() -> String {
        let interval = self.destination.timeIntervalSince(self.origin)
        return self.render(interval, self.type)
    }

    var body: some View {
        Text(label ?? self.buildLabel())
            .onAppear {
                self.adjustmentTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                    self.label = self.buildLabel()
                })
            }
            .onDisappear {
                self.adjustmentTimer?.invalidate()
            }
    }
}

struct DailySessionText: View {
    let session: DailySession

    var body: some View {
        let startDate = self.session.startDate()
        let endDate = self.session.endDate()

        if startDate.timeIntervalSinceNow > 0 {
            return TimeIntervalText(destination: startDate, type: .before)
        } else if endDate.timeIntervalSinceNow > 0 {
            return TimeIntervalText(destination: endDate, type: .during)
        }

        return TimeIntervalText(destination: endDate, type: .after)
    }
}
