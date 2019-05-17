//
//  ViewController.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 23/03/19.
//  Copyright © 2019 Learning. All rights reserved.
//

import UIKit
import WebKit

class GoogleDictionaryViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    var hasFinishedLoading = false
    var searchTerm = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let myUrl = URL(string: "https://www.google.com/search?q=google+dictionary")
        let myRequest = URLRequest(url: myUrl!)
        webView.load(myRequest)
        webView.navigationDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("appeared")
        if (searchTerm != "") {
            searchWord(word: searchTerm)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = """
document.getElementById("sfooter").style.display = "none";
document.getElementById("extrares").style.display = "none";
document.getElementById("taw").style.display = "none";
document.getElementById("qslc").style.display = "none";
document.getElementById("msc").style.display = "none";
document.getElementById("sfcnt").style.display = "none";
document.getElementsByClassName("KojFAc")[0].style.display = "none";
//document.getElementsByClassName("ClBMGc")[0].style.display = "none";
var searchResults = document.getElementsByClassName("g kno-result rQUFld kno-kp mnr-c g-blk")
for (var i = 0; i < searchResults.length; i++) {
searchResults[i].style.display = "none";
}
var searchResults2 = document.getElementsByClassName("srg")
for (var i = 0; i < searchResults2.length; i++) {
searchResults2[i].style.display = "none";
}

document.getElementById("center_col").style.paddingTop = '16px';

//var w = document.getElementsByClassName("JZ1tHe")[0] //this is span. Available only at the beginning
//w.click()

var w = document.getElementsByClassName('YaTjLb')[0] //always available combo box
w.click()

var input = document.querySelector('#sb_ifc50 > input')
print(input != null)
const enterKey = new KeyboardEvent("keydown", {
                    bubbles: true, cancelable: true, keyCode: 13
                });
"""

        webView.evaluateJavaScript(js) { (_, _) in
            self.hasFinishedLoading = true
        }
    }
    
    func searchWord(word: String) {
        if !hasFinishedLoading {
            return
        }
        
        let js = """
                if (input == null) {
                    input = document.querySelector('#sb_ifc50 > input')
                }
                input.value = "\(word)"
                input.dispatchEvent(enterKey)
                """
        
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

}

