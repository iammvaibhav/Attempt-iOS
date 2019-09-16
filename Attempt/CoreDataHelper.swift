//
//  CoreDataHelper.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 19/08/19.
//  Copyright © 2019 Learning. All rights reserved.
//

import Foundation
import CoreData

class Entities {
    static var Word: NSEntityDescription = {
        guard let entity = NSEntityDescription.entity(forEntityName: "Word", in: CoreDataStack.object.managedObjectContext) else {
            fatalError("Error creating entity description: Word)")
        }
        return entity
    }()
}

func getWordFromStore(word: String) -> Word? {
    let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word == %@", word)
    
    do {
        let results = try CoreDataStack.object.managedObjectContext.fetch(fetchRequest)
        return results.first
    } catch {
        print("Error while retreiving results \(error)")
    }
    
    return nil
}
