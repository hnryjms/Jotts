//
//  DarkHostingController.swift
//  Jotts
//
//  Created by Hank Brekke on 10/19/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import UIKit
import SwiftUI

// See https://stackoverflow.com/a/57571698
class DarkHostingController<ContentView>: UIHostingController<ContentView> where ContentView : View {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
