//
//  DefinitionViewController.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 18/08/19.
//  Copyright © 2019 Learning. All rights reserved.
//

import UIKit
import WebKit

class DefinitionViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var googleDictionary: WKWebView!
    @IBOutlet weak var vocabulary: WKWebView!
    var searchWordDelegate: SearchWord?
    var googleDictionaryHasFinishedLoading = false
    var vocabularyHasFinishedLoading = false
    
    override func viewDidLoad() {
        /**
         * Google Dictionary setup
         */
        let googleDictionaryURL = URL(string: "https://www.google.com/search?q=google+dictionary")
        let googleDictionaryRequest = URLRequest(url: googleDictionaryURL!)
        googleDictionary.load(googleDictionaryRequest)
        googleDictionary.navigationDelegate = self
        googleDictionary.configuration.userContentController.add(self, name: "wordNotification")
        
        /**
         * Vocabulary Setup
         */
        let vocabularyURL = URL(string: "https://www.vocabulary.com/dictionary")
        let vocabularyRequest = URLRequest(url: vocabularyURL!)
        vocabulary.load(vocabularyRequest)
        vocabulary.navigationDelegate = self
        vocabulary.configuration.userContentController.add(self, name: "wordNotification")
    }
    
    func searchWord(word: String) {
        googleDictionarySearch(word: word)
        vocabularySearch(word: word)
    }
    
    func swapViews() {
        view.exchangeSubview(at: 0, withSubviewAt: 1)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "wordNotification", let messageBody = message.body as? String {
            //print(messageBody) got the word. Now set it as the searched word
            let searchTerm = messageBody
            searchWordDelegate?.searchWord(searchWord: searchTerm, pushInStack: true, onlyItem: true)
            googleDictionarySearch(word: searchTerm)
            vocabularySearch(word: searchTerm)
        }
    }
    
    func googleDictionarySearch(word: String) {
        if !googleDictionaryHasFinishedLoading {
            return
        }
        
        let js =
        """
        if (input == null) {
            input = document.querySelector('#sb_ifc50 > input')
        }
        
        input.value = "\(word)"
        input.dispatchEvent(new KeyboardEvent("keydown", {
        bubbles: true, cancelable: true, keyCode: 13
        }));
        """
        
        googleDictionary.evaluateJavaScript(js, completionHandler: nil)
    }
    
    func vocabularySearch(word: String) {
        if !vocabularyHasFinishedLoading {
            return
        }
        
        
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
        
        if (document.getElementsByClassName("wordPage clearfloat content-wrapper")[0])
            document.getElementsByClassName("wordPage clearfloat content-wrapper")[0].style.paddingTop = "0px";
        console.log("js finished searching word \(word)")
        
        var ads = document.getElementsByClassName("adslot")
        for (var i = 0; i < ads.length; i++) {
            ads[i].style.display = "none";
        }
        
        function clicked(i) {
        window.webkit.messageHandlers.wordNotification.postMessage(String(i.innerText));
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
        
        vocabulary.evaluateJavaScript(js) { (a,e) in
            print("""
                \(e?.localizedDescription ?? "error")
                """)
            print("completed searching word \(word)") }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if (webView == googleDictionary) {
            let js =
            """
            if (document.getElementById("sfooter"))
                document.getElementById("sfooter").style.display = "none";

            if (document.getElementById("extrares"))
                document.getElementById("extrares").style.display = "none";

            if (document.getElementById("taw"))
                document.getElementById("taw").style.display = "none";

            if (document.getElementById("qslc"))
                document.getElementById("qslc").style.display = "none";

            if (document.getElementById("msc"))
                document.getElementById("msc").style.display = "none";

            if (document.getElementById("sfcnt"))
                document.getElementById("sfcnt").style.display = "none";

            let ads1 = document.getElementsByClassName("KojFAc")
            if (ads1.length > 0) {
                document.getElementsByClassName("KojFAc")[0].style.display = "none";
            }

            let ads2 = document.getElementsByClassName("XqIXXe")
            if (ads2.length > 0) {
                document.getElementsByClassName("XqIXXe")[0].style.display = "none"
            }

            let ads3 = document.getElementsByClassName("u0jb6e")
            if (ads3.length > 0) {
                document.getElementsByClassName("u0jb6e")[0].style.display = "none";
            }
            
            var searchResults = document.getElementsByClassName("g kno-result rQUFld kno-kp mnr-c g-blk")
            for (var i = 0; i < searchResults.length; i++) {
                searchResults[i].style.display = "none";
            }

            var searchResults2 = document.getElementsByClassName("srg")
            for (var i = 0; i < searchResults2.length; i++) {
                searchResults2[i].style.display = "none";
            }

            if (document.getElementById("center_col"))
                document.getElementById("center_col").style.paddingTop = '16px';

            var w = document.getElementsByClassName('YaTjLb')[0] //always available combo box
            w.style.display = "none";
            w.click()

            var input = document.querySelector('#sb_ifc50 > input')
            print(input != null)
            const enterKey = new KeyboardEvent("keydown", {
                    bubbles: true, cancelable: true, keyCode: 13
            });

            function clicked(i) {
                window.webkit.messageHandlers.wordNotification.postMessage(i.getAttribute("data-term-for-update"));
            }

            function monitorLinks() {
                var elements = Array.from(document.getElementsByTagName("span")).filter(element => element.className == 'SDZsVb');
                for(var i=0; i<elements.length; i++){
                    elements[i].onclick = (function(opt) {
                        return function() {
                            clicked(opt);
                        };
                    })(elements[i]);
                }
            }

            let oldXHROpen = window.XMLHttpRequest.prototype.open;
            window.XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
            // do something with the method, url and etc.
            this.addEventListener('load', function() {
            // do something with the response text
            //console.log('load: ' + this.responseText);
            document.getElementsByClassName("duf3")[0].style.display = "none";
            document.getElementsByClassName("iXqz2e aI3msd xpdarr mv83Pc pSO8Ic vk_arc")[0].style.display = "none";
            //document.getElementsByClassName("zbA8Me gJBeNe vSuuAd")[0].style.display = "none";
            document.getElementsByClassName('YaTjLb')[0].style.display = "none";
            document.getElementsByClassName("lr_dct_ent vmod XpoqFe")[0].style.paddingTop = '0px';
            setTimeout(monitorLinks, 200)
            });
               
            return oldXHROpen.apply(this, arguments);
            }
            """
            
            googleDictionary.evaluateJavaScript(js) { (_, _) in
                self.googleDictionaryHasFinishedLoading = true
            }
            
        } else if (webView == vocabulary) {
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

                    var ads = document.getElementsByClassName("adslot")
                    for (var i = 0; i < ads.length; i++) {
                        ads[i].style.display = "none";
                    }

                    var input = document.querySelector('#search')
                    const enterKey = new KeyboardEvent("keydown", {
                        bubbles: true, cancelable: true, keyCode: 13
                    });
                    """
            
            vocabulary.evaluateJavaScript(js) { (_, _) in
                self.vocabularyHasFinishedLoading = true
            }
        }
    }

}

