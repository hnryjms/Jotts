//
// Created by Hank Brekke on 10/1/17.
// Copyright (c) 2017 Hank Brekke. All rights reserved.
//

import UIKit

extension UIViewController {
    var topNavigationController: UINavigationController? {
        get {
            var navigationController = self.navigationController
            while let upperNavigationController = navigationController?.navigationController {
                navigationController = upperNavigationController
            }
            return navigationController
        }
    }
}
