//
// Created by Hank Brekke on 1/1/17.
// Copyright (c) 2017 Hank Brekke. All rights reserved.
//

import SwiftUI

extension Color {
    init(fromHex hex: String?, fallback: ColorHex = ColorHex.teal) {
        let r, g, b, a: Double

        let start: String.Index
        let hexColor: String
        if let hexCode = hex, hexCode.starts(with: "#"), hexCode.count == 9 {
            start = hexCode.index(hexCode.startIndex, offsetBy: 1)
            hexColor = String(hexCode[start...])
        } else {
            start = fallback.rawValue.index(fallback.rawValue.startIndex, offsetBy: 1)
            hexColor = String(fallback.rawValue[start...])
        }

        var hexNumber: UInt64 = 0
        let scanner = Scanner(string: hexColor)
        scanner.scanHexInt64(&hexNumber)

        r = Double((hexNumber & 0xff000000) >> 24) / 255
        g = Double((hexNumber & 0x00ff0000) >> 16) / 255
        b = Double((hexNumber & 0x0000ff00) >> 8) / 255
        a = Double(hexNumber & 0x000000ff) / 255

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
