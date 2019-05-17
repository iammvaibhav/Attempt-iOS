//
//  VocabularyViewController.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 24/03/19.
//  Copyright © 2019 Learning. All rights reserved.
//

import UIKit
import WebKit

class VocabularyViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    var hasFinishedLoading = false
    var searchTerm = "" {
        didSet {
            print("search term did set to \(searchTerm)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let myUrl = URL(string: "https://www.vocabulary.com/dictionary")
        let myRequest = URLRequest(url: myUrl!)
        webView.load(myRequest)
        webView.navigationDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("vocab appeared")
        if (searchTerm != "") {
            searchWord(word: searchTerm)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js =    """
                    if (document.getElementById('google_ads_iframe_/15665503/Dictionary-Result-Right_0')) document.getElementById('google_ads_iframe_/15665503/Dictionary-Result-Right_0').outerHTML = ""
                    if(document.getElementsByClassName('leaderboard-ad')[0]) document.getElementsByClassName('leaderboard-ad')[0].style.display = 'none';
                    if (document.getElementsByClassName("page-header noselect")[0]) document.getElementsByClassName("page-header noselect")[0].style.display = "none";
                    if (document.getElementsByClassName("fixed-tray")[0]) document.getElementsByClassName("fixed-tray")[0].style.display = "none";
                    if (document.getElementById("dictionaryNav")) document.getElementById("dictionaryNav").style.display = "none";
                    if (document.getElementsByClassName("signup-tout center clearfloat sectionbg")[0]) document.getElementsByClassName("signup-tout center clearfloat sectionbg")[0].style.display = 'none';
                    if (document.getElementsByClassName("page-footer")[0]) document.getElementsByClassName("page-footer")[0].style.display = 'none';
                    var input = document.querySelector('#search')
                    const enterKey = new KeyboardEvent("keydown", {
                        bubbles: true, cancelable: true, keyCode: 13
                    });
                    """
        
        webView.evaluateJavaScript(js) { (_, _) in
            print("has finished loading")
            self.hasFinishedLoading = true
        }
    }
    
    
    func searchWord(word: String) {
        if !hasFinishedLoading {
            return
        }
        print("searching word \(word)")
        let js = """
        alert("js searching word \(word)")
        console.log("js searching word \(word)")
        input.value = "\(word)"
        input.dispatchEvent(enterKey)
        
        jQuery(document).ajaxStop(function() {
        if (document.getElementById('dictionary-upper-ad')) document.getElementById('dictionary-upper-ad').style.display = 'none';
        if (document.getElementsByClassName('leaderboard-ad')) document.getElementsByClassName('leaderboard-ad')[0].style.display = 'none';
        if (document.getElementById('google_ads_iframe_/15665503/Dictionary-Result-Right_0')) document.getElementById('google_ads_iframe_/15665503/Dictionary-Result-Right_0').outerHTML = ""
        if (document.getElementsByClassName("section related nocontent robots-nocontent screen-only")[0]) document.getElementsByClassName("section related nocontent robots-nocontent screen-only")[0].style.display = 'none';
        if (document.getElementsByClassName("wordPage vocab blurbed clearfloat content-wrapper")[0]) document.getElementsByClassName("wordPage vocab blurbed clearfloat content-wrapper")[0].style.paddingTop = '0px';
        if (document.getElementsByClassName("definitionsContainer")[0]) document.getElementsByClassName("definitionsContainer")[0].firstElementChild.style.width = '100%';
        console.log("js finished searching word \(word)")
        })
        """
        
        webView.evaluateJavaScript(js) { (a,e) in
            print("""
                \(e?.localizedDescription ?? "error")
                """)
            print("completed searching word \(word)") }
    }

}
