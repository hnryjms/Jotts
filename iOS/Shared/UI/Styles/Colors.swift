//
//  Colors.swift
//  Jotts
//
//  Created by Hank Brekke on 12/14/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

extension Color {
    struct Jotts {
        static var background: Color { return Color(.sRGB, white: 0.26) }
        static var textPlaceholder: Color { return Color(.sRGB, white: 0.65) }
    }
}

enum ColorHex: String {
    case orange = "#ff8100ff"
    case pink = "#ff0080ff"
    case green = "#00b60eff"
    case red = "#e72b00ff"
    case lightGreen = "#83f218ff"
    case lightPurple = "#c66bffff"
    case teal = "#00b190ff"
    case darkBlue = "#0e4dffff"
    case purple = "#7a40a3ff"
    case brown = "#996600ff"
}

extension ColorHex {
    static var sorted: [ColorHex] = [ .orange, .pink, .green, .red, .lightGreen, .lightPurple, .teal, .darkBlue, .purple, .brown ]
}
