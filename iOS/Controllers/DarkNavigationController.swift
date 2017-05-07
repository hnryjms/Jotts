//
// Created by Hank Brekke on 5/7/17.
// Copyright (c) 2017 Hank Brekke. All rights reserved.
//

import UIKit

class DarkNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}
