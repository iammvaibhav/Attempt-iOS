//
//  DataSouce.swift
//  Learning View Controllers
//
//  Created by Vaibhav Maheshwari on 17/08/19.
//  Copyright © 2019 Learning. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class WordSuggestionDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var items = [String]()
    var searchWordDelegate: SearchWord?
    var ref: DatabaseReference?
    
    override init() {
        ref = Database.database().reference().child("words")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wordSuggestion", for: indexPath)
        cell.clipsToBounds = false
        let wordView = (cell.contentView.subviews.first as! WordSuggestionView)
        wordView.text = items[indexPath.row]
        ref?.child(items[indexPath.row]).observeSingleEvent(of: .value) {
            let exists = $0.exists()
            DispatchQueue.main.async {
                wordView.displayType = exists ? .FAVOURITE : .NORMAL
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let rect = items[indexPath.row].boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 16.0)!], context: nil)
        
        
        return CGSize(width: ceil(rect.width) + 50, height: ceil(rect.height) + 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 { //favourite toggle
            if let cell = collectionView.cellForItem(at: indexPath)?.contentView.subviews.first as? WordSuggestionView {
                
                switch cell.displayType {
                case .NORMAL:
                    cell.displayType = .FAVOURITE
//                    let wordToAdd = Word(entity: Entities.Word, insertInto: CoreDataStack.object.managedObjectContext)
//                    wordToAdd.dateAdded = NSDate()
//                    wordToAdd.word = cell.text!
                    ref?.child(cell.text!).setValue(Date().timeIntervalSince1970)
                case .FAVOURITE:
                    cell.displayType = .NORMAL
                    ref?.child(cell.text!).removeValue()
//                    if let word = getWordFromStore(word: cell.text!) {
//                        CoreDataStack.object.managedObjectContext.delete(word)
//                    }
                }
                //CoreDataStack.object.saveMainContext()
                
            }
        } else {
            searchWordDelegate?.searchWord(searchWord: items[indexPath.row], pushInStack: true, onlyItem: true)
        }
    }
    
}
