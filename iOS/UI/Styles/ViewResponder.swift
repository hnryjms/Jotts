//
//  ViewResponder.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

extension View {
    var next: AppResponder {
        get { AppDelegate.sharedDelegate().responder }
    }
}
