//
//  Colors.swift
//  Jotts
//
//  Created by Hank Brekke on 12/14/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import UIKit

extension UIColor {
    struct Jotts {
        static var background: UIColor { return UIColor(white: 0.26, alpha: 1) }
        static var textPlaceholder: UIColor { return UIColor(white: 0.65, alpha: 1) }
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
