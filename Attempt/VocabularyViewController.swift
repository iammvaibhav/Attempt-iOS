//
//  VocabularyViewController.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 24/03/19.
//  Copyright © 2019 Learning. All rights reserved.
//

import UIKit
import WebKit

class VocabularyViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "test", let messageBody = message.body as? String {
            //print(messageBody) got the word. Now set it as the searched word
            self.searchTerm = messageBody
            (self.tabBarController?.viewControllers?[0] as! GoogleDictionaryViewController).searchTerm = messageBody
            ((self.tabBarController?.splitViewController?.viewControllers[0] as! UINavigationController).viewControllers[0] as! MasterViewController).searchController.searchBar.text = messageBody
        }
    }
    
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
        let x = webView.configuration.userContentController
        x.add(self, name: "test")
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
                    if (document.getElementsByClassName("learn")[0])
                        document.getElementsByClassName("learn")[0].style.display = 'none';
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
        if (document.getElementsByClassName("learn")[0])
            document.getElementsByClassName("learn")[0].style.display = 'none';
        console.log("js finished searching word \(word)")
        
        function clicked(i) {
        window.webkit.messageHandlers.test.postMessage(String(i.innerText));
        }
        
        function monitorLinks() {
        var elements = Array.from(document.getElementsByTagName("a")).filter(element => element.className == 'word');
        for(var i=0; i<elements.length; i++){
        elements[i].onclick = (function(opt) {
        return function() {
        clicked(opt);
        };
        })(elements[i]);
        }
        }
        
        monitorLinks()
        })
        """
        
        webView.evaluateJavaScript(js) { (a,e) in
            print("""
                \(e?.localizedDescription ?? "error")
                """)
            print("completed searching word \(word)") }
    }

}
