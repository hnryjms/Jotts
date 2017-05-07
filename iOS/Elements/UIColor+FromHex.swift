//
// Created by Hank Brekke on 1/1/17.
// Copyright (c) 2017 Hank Brekke. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init?(fromHex hex: String?) {
        let hexCode: String? = hex?.trimmingCharacters(in: (CharacterSet.alphanumerics).inverted).uppercased()

        guard hexCode?.characters.count == 6 else {
            return nil
        }

        var rgbValue: UInt32 = 0
        Scanner(string: hexCode!).scanHexInt32(&rgbValue)

        self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
        )
    }
}
