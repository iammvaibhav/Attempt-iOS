//
//  Word+CoreDataProperties.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 19/08/19.
//  Copyright © 2019 Learning. All rights reserved.
//
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var word: String
    @NSManaged public var dateAdded: NSDate

}
