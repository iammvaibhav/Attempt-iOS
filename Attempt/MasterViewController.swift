//
//  MasterViewController.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 24/03/19.
//  Copyright © 2019 Learning. All rights reserved.
//

import UIKit
import Foundation

typealias SearchResult = [PurpleSearchResult]

enum PurpleSearchResult: Codable {
    case searchResultClass(SearchResultClass)
    case string(String)
    case unionArrayArray([[SearchResultSearchResultUnion]])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([[SearchResultSearchResultUnion]].self) {
            self = .unionArrayArray(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(SearchResultClass.self) {
            self = .searchResultClass(x)
            return
        }
        throw DecodingError.typeMismatch(PurpleSearchResult.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for PurpleSearchResult"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .searchResultClass(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        case .unionArrayArray(let x):
            try container.encode(x)
        }
    }
}

enum SearchResultSearchResultUnion: Codable {
    case integer(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(SearchResultSearchResultUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SearchResultSearchResultUnion"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

struct SearchResultClass: Codable {
    let q: String
}

class MasterViewController: UIViewController, UISearchResultsUpdating, SearchWord, UITableViewDataSource, UITableViewDelegate {
    
    var wordsList = [String]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath)
        cell.textLabel?.text = wordsList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchWord(searchWord: wordsList[indexPath.row])
    }
    
    func addFavourite() {
        wordsList.append(searchWordString)
        //persist list
        UserDefaults.standard.set(wordsList, forKey: "wordsList")
        print(wordsList)
        print(UserDefaults.standard.object(forKey: "wordsList") as! [String])
        tableView.reloadData()
    }
    
    func isFavourite() -> Bool {
        return wordsList.contains(searchWordString)
    }
    
    func removeFavourite() {
        wordsList.removeAll(where: { $0 == searchWordString })
        print(wordsList)
        UserDefaults.standard.set(wordsList, forKey: "wordsList")
        print(UserDefaults.standard.object(forKey: "wordsList") as! [String])
        tableView.reloadData()
    }
    
    var searchController: UISearchController!
    private var searchResultsController: SearchResultsTableViewController!
    var task: URLSessionDataTask?
    @IBOutlet weak var tableView: UITableView!
    var searchWordString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let words = UserDefaults.standard.object(forKey: "wordsList") as? [String] {
            print("I am here")
            print(words)
            wordsList.append(contentsOf: words)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        searchResultsController = storyboard.instantiateViewController(withIdentifier: "searchResultsTableViewController") as? SearchResultsTableViewController
        searchResultsController.searchWord = self
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Words"
        definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            // For iOS 11 and later, place the search bar in the navigation bar.
            navigationItem.searchController = searchController
            // Make the search bar always visible.
            navigationItem.hidesSearchBarWhenScrolling = false
            navigationItem.title = "Attempt"
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            //TODO
            //tableView.tableHeaderView = searchController.searchBar
        }
        // Do any additional setup after loading the view.
        (self.splitViewController?.viewControllers[1] as! UITabBarController).viewControllers?.forEach {
            let _ = $0.view
        }
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
                
                self.searchResultsController.suggestions.removeAll()
                
                let sr = searchResult![1]
                switch sr {
                    case .unionArrayArray(let union):
                        for i in union {
                            switch i[0] {
                            case .string(let data):
                    self.searchResultsController.suggestions.append(data.stringByDecodingHTMLEntities)
                            default: break
                            }
                        }
                    default: break
                }
                
          
                DispatchQueue.main.async {
                    if let firstSuggestion = self.searchResultsController.suggestions.first {
                        self.searchWord(searchWord: firstSuggestion)
                    }
                    self.searchResultsController.tableView.reloadData()
                }
                
            }
        }
        self.task?.resume()
    }
    
    func updateSearchResults(for
        searchController: UISearchController) {
        //TODO
        //searchController.searchResultsController?.view.isHidden = false
        if let searchText  = searchController.searchBar.text {
            if (searchText != "") {
                loadAndShowSuggestions(userInput: searchText)
            }
        }
    }
    
    func searchWord(searchWord: String) {
        searchWordString = searchWord
        if (isFavourite()) {
            (splitViewController as? RootSplitViewController)?.bt1.setClicked(true, animated: false)
        } else {
            (splitViewController as? RootSplitViewController)?.bt1.setClicked(false, animated: false)
        }
        ((self.splitViewController?.viewControllers[1] as! UITabBarController).viewControllers![0] as! GoogleDictionaryViewController).searchTerm = searchWord
        ((self.splitViewController?.viewControllers[1] as! UITabBarController).viewControllers![1] as! VocabularyViewController).searchTerm = searchWord
        ((self.splitViewController?.viewControllers[1] as! UITabBarController).viewControllers![0] as! GoogleDictionaryViewController).searchWord(word: searchWord)
        ((self.splitViewController?.viewControllers[1] as! UITabBarController).viewControllers![1] as! VocabularyViewController).searchWord(word: searchWord)
    }
}

// Mapping from XML/HTML character entity reference to character
// From http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
private let characterEntities : [ Substring : Character ] = [
    // XML predefined entities:
    "&quot;"    : "\"",
    "&amp;"     : "&",
    "&apos;"    : "'",
    "&lt;"      : "<",
    "&gt;"      : ">",
    
    // HTML character entity references:
    "&nbsp;"    : "\u{00a0}",
    // ...
    "&diams;"   : "♦",
]

extension String {
    
    /// Returns a new string made by replacing in the `String`
    /// all HTML character entity references with the corresponding
    /// character.
    var stringByDecodingHTMLEntities : String {
        
        // ===== Utility functions =====
        
        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(_ string : Substring, base : Int) -> Character? {
            guard let code = UInt32(string, radix: base),
                let uniScalar = UnicodeScalar(code) else { return nil }
            return Character(uniScalar)
        }
        
        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(_ entity : Substring) -> Character? {
            
            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X") {
                return decodeNumeric(entity.dropFirst(3).dropLast(), base: 16)
            } else if entity.hasPrefix("&#") {
                return decodeNumeric(entity.dropFirst(2).dropLast(), base: 10)
            } else {
                return characterEntities[entity]
            }
        }
        
        // ===== Method starts here =====
        
        var result = ""
        var position = startIndex
        
        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self[position...].range(of: "&") {
            result.append(contentsOf: self[position ..< ampRange.lowerBound])
            position = ampRange.lowerBound
            
            // Find the next ';' and copy everything from '&' to ';' into `entity`
            guard let semiRange = self[position...].range(of: ";") else {
                // No matching ';'.
                break
            }
            let entity = self[position ..< semiRange.upperBound]
            position = semiRange.upperBound
            
            if let decoded = decode(entity) {
                // Replace by decoded character:
                result.append(decoded)
            } else {
                // Invalid entity, copy verbatim:
                result.append(contentsOf: entity)
            }
        }
        // Copy remaining characters to `result`:
        result.append(contentsOf: self[position...])
        return result
    }
}
