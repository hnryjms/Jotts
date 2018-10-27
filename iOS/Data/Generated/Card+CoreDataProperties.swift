//
//  Card+CoreDataProperties.swift
//  Jotts
//
//  Created by Hank Brekke on 10/27/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//
//

import Foundation
import CoreData

extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var details: String?
    @NSManaged public var image: NSData?
    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var deck: Deck?

}
