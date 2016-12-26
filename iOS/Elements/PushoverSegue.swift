//
//  PushoverSegue.swift
//  Jotts
//
//  Created by Hank Brekke on 8/26/14.
//  Copyright (c) 2014 z43 Studio. All rights reserved.
//

import UIKit

@objc(PushoverSegue)
class PushoverSegue: UIStoryboardSegue {
	
	override func perform() {
		if UIDevice.current.userInterfaceIdiom == .pad {
			// TODO: Popover view.
		} else {
			let navigationController = self.source.navigationController as UINavigationController!;
			
			navigationController?.pushViewController(self.destination, animated: true);
		}
	}
}
