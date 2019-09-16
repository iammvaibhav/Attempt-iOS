//
//  MainScreenViewController.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 01/06/19.
//  Copyright © 2019 Learning. All rights reserved.
//

import UIKit
import Foundation

class MainScreenViewController: UIViewController, UISearchBarDelegate, SearchWord, UIGestureRecognizerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var task: URLSessionDataTask?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var definitionViewToggleButton: UIButton!
    @IBOutlet weak var wordSuggestionCollectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var definitionsContainerView: UIView!
    @IBOutlet weak var homeContainerView: UIView!
    @IBOutlet weak var sortChangeButton: UIButton!
    @IBOutlet weak var wordSuggestionContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientView: GradientView!
    
    var wordSuggestionDataSource: WordSuggestionDataSource?
    weak var definitionViewController: DefinitionViewController?
    weak var homeViewController: HomeViewController?
    var wordStack = [String]()
    var currSearchWord: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         * Setup search bar
         */
        searchBar.delegate = self
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                
                // Background color
                backgroundview.backgroundColor = UIColor.white
                
                // Rounded corner
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }
        }
        
        /**
         * Setup collection view
         */
        wordSuggestionDataSource = WordSuggestionDataSource()
        wordSuggestionDataSource?.searchWordDelegate = self
        wordSuggestionCollectionView.dataSource = wordSuggestionDataSource
        wordSuggestionCollectionView.delegate = wordSuggestionDataSource
        wordSuggestionCollectionView.clipsToBounds = false
        
        definitionViewToggleButton.setImage(#imageLiteral(resourceName: "googleIconNew"), for: .normal)
        sortChangeButton.setImage(#imageLiteral(resourceName: "recent"), for: .normal)
    }
    
    func loadAndShowSuggestions(userInput: String) {
        self.task?.cancel()
        let url = URL(string: """
            https://www.google.com/complete/search?client=dictionary-widget&requiredfields=corpus%3Aen&q=\(userInput.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)
            """)!
        task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("error happened \(error.localizedDescription)\\")
                return
            }
            
            if let data = data, let string = String(data: data, encoding: .utf8) {
                let searchResult = try? JSONDecoder().decode(SearchResult.self, from: string[string.index(string.startIndex, offsetBy: 19)...string.index(string.endIndex, offsetBy: -2)].data(using: .utf8)!)
                
                self.wordSuggestionDataSource?.items.removeAll()
                
                let sr = searchResult![1]
                switch sr {
                case .unionArrayArray(let union):
                    for i in union {
                        switch i[0] {
                        case .string(let data):
                            self.wordSuggestionDataSource?.items.append(data.stringByDecodingHTMLEntities)
                        default: break
                        }
                    }
                default: break
                }
                
                
                DispatchQueue.main.async {
                    if self.wordSuggestionDataSource?.items.isEmpty ?? false {
                        self.wordSuggestionDataSource?.items.append(userInput)
                        self.definitionViewController?.searchWord(word: userInput)
                    } else {
                        if let firstSuggestion = self.wordSuggestionDataSource?.items.first {
                            self.definitionViewController?.searchWord(word: firstSuggestion)
                            self.currSearchWord = firstSuggestion
                        }
                    }
                    
                    self.wordSuggestionCollectionView.reloadData()
                }
                
            }
        }
        self.task?.resume()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            goHome(backButton)
        } else {
            showSuggestionsAndDefinitions()
            searchWord(searchWord: searchText, pushInStack: false, onlyItem: false)
        }
    }
    
    func searchWord(searchWord: String, pushInStack: Bool, onlyItem: Bool) {
        
        if pushInStack {
            if let currSearch = currSearchWord {
                backButton.isEnabled = true
                wordStack.append(currSearch)
            }
        }
        
        searchBar.text = searchWord
        currSearchWord = searchWord
        
        if !searchWord.isEmpty {
            if onlyItem {
                wordSuggestionDataSource?.items.removeAll()
                wordSuggestionDataSource?.items.append(searchWord)
                wordSuggestionCollectionView.reloadData()
                self.definitionViewController?.searchWord(word: searchWord)
            } else {
                loadAndShowSuggestions(userInput: searchWord)
            }
        }
    }
    
    func showSuggestionsAndDefinitions() {
        wordSuggestionContainerHeightConstraint.constant = 52.0
        view.bringSubviewToFront(definitionsContainerView)
        gradientView.bringSubviewToFront(definitionViewToggleButton)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            wordSuggestionDataSource?.items.removeAll()
            wordSuggestionDataSource?.items.append(searchText)
            wordSuggestionCollectionView.reloadData()
            self.definitionViewController?.searchWord(word: searchText)
        }
    }
    
    @IBAction func changeDefinitionView(_ sender: UIButton) {
        let googleIcon = #imageLiteral(resourceName: "googleIconNew")
        let vocabularyIcon = #imageLiteral(resourceName: "vocabularyIconNew")
        
        if sender.image(for: .normal) == googleIcon {
            sender.setImage(vocabularyIcon, for: .normal)
        } else {
            sender.setImage(googleIcon, for: .normal)
        }
        
        definitionViewController?.swapViews()
    }
    
    @IBAction func changeSort(_ sender: UIButton) {
        let alphabetical = #imageLiteral(resourceName: "alphabetical")
        let recent = #imageLiteral(resourceName: "recent")
        
        if sender.image(for: .normal) == alphabetical {
            sender.setImage(recent, for: .normal)
        } else {
            sender.setImage(alphabetical, for: .normal)
        }
        
        homeViewController?.swapSort()
    }
    
    @IBAction func goHome(_ sender: UIButton) {
        searchBar.text = ""
        homeViewController?.reloadData()
        wordSuggestionContainerHeightConstraint.constant = 0.0
        wordStack.removeAll()
        backButton.isEnabled = false
        view.bringSubviewToFront(homeContainerView)
        gradientView.bringSubviewToFront(sortChangeButton)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        if let goTo = wordStack.popLast() {
            searchWord(searchWord: goTo, pushInStack: false, onlyItem: false)
            if wordStack.isEmpty {
                backButton.isEnabled = false
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let definitionViewController = segue.destination as? DefinitionViewController {
            self.definitionViewController = definitionViewController
            definitionViewController.searchWordDelegate = self
        } else if let homeViewController = segue.destination as? HomeViewController {
            self.homeViewController = homeViewController
            homeViewController.searchWordDelegate = self
        }
    }
}
