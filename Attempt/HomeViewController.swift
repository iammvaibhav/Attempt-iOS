//
//  HomeViewController.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 21/08/19.
//  Copyright © 2019 Learning. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct Wordd {
    var word: String
    var dateAdded: Date
}

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var itemSize = [CGSize]()
    var items = [Wordd]()
    let itemFontName = "Helvetica-Bold"
    //let itemFontName = "Noteworthy-Bold"
    let itemFontSize = CGFloat(20.0)
    let cellHorizontalPadding = CGFloat(50.0)
    let cellVerticalPadding = CGFloat(12.0)
    var firstTime = true
    var searchWordDelegate: SearchWord?
    var sortBy = "dateAdded"
    var sortAscending = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Database.database().reference().child("words")
        
        ref.observeSingleEvent(of: .value) {
            let children = $0.childrenCount
            var first = true
            
            ref.observe(.childAdded) {
                self.items.append(Wordd(word: $0.key, dateAdded: Date(timeIntervalSince1970: TimeInterval(exactly: $0.value as! Double)!)))
                
                if !first {
                    self.sortByCurrentSelection()
                    
                    DispatchQueue.main.async {
                        self.updateLayoutInfo(collectionViewWidth: self.collectionView.frame.width - 20.0)
                        self.collectionView.reloadData()
                    }
                }
                
                if first && self.items.count < children {
                    return
                } else if first && self.items.count == children {
                    first = false
                    self.sortByCurrentSelection()
                    
                    DispatchQueue.main.async {
                        self.updateLayoutInfo(collectionViewWidth: self.collectionView.frame.width - 20.0)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        
        ref.observe(.childRemoved) {
            let toRemove = $0.key
            self.items.removeAll { $0.word == toRemove }
            self.sortByCurrentSelection()
            
            DispatchQueue.main.async {
                self.updateLayoutInfo(collectionViewWidth: self.collectionView.frame.width - 20.0)
                self.collectionView.reloadData()
            }
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "word", for: indexPath)
        let gradientView = (cell.contentView.subviews.first as! GradientView)
        gradientView.layer.masksToBounds = true
        gradientView.layer.cornerRadius = CGFloat(5.0)
        if let gradient = gradients.randomElement() {
            gradientView.startColor = gradient.0
            gradientView.endColor = gradient.1
        }
        
        (cell.contentView.subviews.first?.subviews.first as! UILabel).text = items[indexPath.row].word
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize[indexPath.row]
    }
    
//    func updateData() {
//        // fetch items from store
//        items.removeAll()
//        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortBy, ascending: sortAscending, selector: #selector(NSString.caseInsensitiveCompare))]
//
//        do {
//            let results = try CoreDataStack.object.managedObjectContext.fetch(fetchRequest)
//            items.append(contentsOf: results)
//        } catch {
//            print("Error in fetching \(error)")
//        }
//    }
    
    func updateLayoutInfo(collectionViewWidth: CGFloat) {
        itemSize.removeAll()
        
        //calculate sizes and store in itemSize array
        var currItem = 0
        
        /**
         * First find how many elements can fit in a row.
         * Then divide the remaining space equally among the items in the row.
         * Repeat for all rows
         */
        let itemSpacing = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing
        
        while currItem < items.count {
            let startedAt = currItem
            var allocatedSpace = CGFloat(0.0)
            
            while currItem < items.count {
                let rect = items[currItem].word.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont(name: itemFontName, size: itemFontSize)!], context: nil)
                
                let cellWidth = ceil(rect.width) + 2 * cellHorizontalPadding
                let cellHeight = ceil(rect.height) + 2 * cellVerticalPadding
                
                if allocatedSpace + cellWidth + CGFloat((currItem - startedAt)) * itemSpacing <= collectionViewWidth {
                    allocatedSpace += cellWidth
                    itemSize.append(CGSize(width: cellWidth, height: cellHeight))
                    currItem += 1
                } else { //current item doesn't fit in the current row
                    //distribute the remaining space into items and break
                    let remainingSpace = collectionViewWidth - allocatedSpace - CGFloat((currItem - startedAt - 1)) * itemSpacing
                    let numOfItems = currItem - startedAt
                    let allocationToEach = floor(remainingSpace / CGFloat(numOfItems))

                    for item in startedAt..<currItem {
                        itemSize[item].width += allocationToEach
                    }
                    
                    
                    break
                }
            }
        }
    }
    
    func reloadData() {
        //updateData()
        updateLayoutInfo(collectionViewWidth: collectionView.frame.width - 20.0)
        collectionView.reloadData()
    }
    
    func swapSort() {
        sortAscending = !sortAscending
        if sortBy == "dateAdded" {
            sortBy = "word"
            items.sort { $0.word.lowercased() < $1.word.lowercased() }
        } else {
            sortBy = "dateAdded"
            items.sort { ($0.dateAdded as Date) > ($1.dateAdded as Date) }
        }
        updateLayoutInfo(collectionViewWidth: collectionView.frame.width - 20.0)
        //collectionView.reloadData()
        self.collectionView.performBatchUpdates({ self.collectionView.reloadSections(IndexSet.init(integer: 0)) }, completion: nil)
    }
    
    func sortByCurrentSelection() {
        if sortBy == "dateAdded" {
            items.sort { ($0.dateAdded as Date) > ($1.dateAdded as Date) }
        } else {
            items.sort { $0.word.lowercased() < $1.word.lowercased() }
        }
    }
    
    override func viewDidLayoutSubviews() {
        if firstTime {
            firstTime = false
            reloadData()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateLayoutInfo(collectionViewWidth: size.width - 20.0)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20.0, left: 10.0, bottom: 0.0, right: 10.0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchWordDelegate?.showSuggestionsAndDefinitions()
        searchWordDelegate?.searchWord(searchWord: items[indexPath.row].word, pushInStack: false, onlyItem: true)
    }

}
