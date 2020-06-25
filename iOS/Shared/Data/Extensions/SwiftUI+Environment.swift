//
//  SwiftUI+Environment.swift
//  Jotts
//
//  Created by Hank Brekke on 6/24/20.
//  Copyright © 2020 Hank Brekke. All rights reserved.
//

import SwiftUI

struct BuildingKey: EnvironmentKey {
    static let defaultValue: Building = Building.infer(context: globalViewContext)
}

extension EnvironmentValues {
    var building: Building {
        get {
            self[BuildingKey.self]
        }
        set {
            self[BuildingKey.self] = newValue
        }
    }
}
