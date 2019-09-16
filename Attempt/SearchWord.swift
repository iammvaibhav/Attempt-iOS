//
//  SearchWord.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 25/03/19.
//  Copyright © 2019 Learning. All rights reserved.
//

public protocol SearchWord {
    func searchWord(searchWord: String, pushInStack: Bool, onlyItem: Bool)
    func showSuggestionsAndDefinitions()
}
