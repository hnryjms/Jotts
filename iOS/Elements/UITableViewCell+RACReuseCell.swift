//
//  UITableViewCell+RACReuseCell.swift
//  Jotts
//
//  Created by Hank Brekke on 12/11/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit
import ReactiveCocoa

// https://github.com/ReactiveCocoa/ReactiveCocoa/issues/2282#issuecomment-138495622

extension UITableViewCell {
    var rac_prepareForReuseProducer: SignalProducer<Void, NoError> {
        return rac_prepareForReuseSignal
            .toSignalProducer()
            .flatMapError({ _ in return SignalProducer<AnyObject?, NoError>.empty })
            .map({ _ in })
    }
}
