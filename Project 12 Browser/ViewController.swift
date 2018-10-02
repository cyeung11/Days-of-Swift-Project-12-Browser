//
//  ViewController.swift
//  Project 12 Browser
//
//  Created by Chris on 1/10/2018.
//  Copyright © 2018 Chris. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {

    var lastAddress = ""
    var lastAddressBarAttributeText: NSAttributedString?
    
    @IBOutlet weak var reloadBkg: UIView!{
        didSet{
            reloadBkg.layer.cornerRadius = 10.0
            reloadBkg.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var addressBar: UITextField!{
        didSet{
            addressBar.delegate = self
        }
    }
    @IBOutlet weak var webview: WKWebView!{
        didSet{
            webview.navigationDelegate = self
            let myURL = URL(string:"https://www.google.com")
            let myRequest = URLRequest(url: myURL!)
            webview.load(myRequest)
            webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
    }
    
    @IBAction func go(_ sender: Any) {
        
        let appleURL = URL(string:"https://www.apple.com")
        var myRequest = URLRequest(url: appleURL!)
        
        if let address = addressBar.text,
            !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            
            var modifiedAddress = address
            
            if modifiedAddress.contains("."),
                !modifiedAddress.hasPrefix("http://"), !modifiedAddress.hasPrefix("https://"){
                modifiedAddress.insert(contentsOf: "http://", at: modifiedAddress.startIndex)
            } else if !modifiedAddress.contains("."), !modifiedAddress.hasPrefix("http"){
                search(self)
                return
            }
            
            if let myURL = URL(string: modifiedAddress) {
                myRequest = URLRequest(url: myURL)
            }
        }
        webview.load(myRequest)
        addressBar.resignFirstResponder()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    

    @IBAction func reload(_ sender: Any) {
        webview.reload()
        
        reloadBkg.alpha = 0.0
        reloadBkg.isHidden = false
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveLinear,
                       animations: {
                        self.reloadBkg.alpha = 1.0
        }) { finish in
            if finish{
                UIView.animate(withDuration: 0.3,
                               delay: 0.7,
                               options: .curveLinear,
                               animations: {
                                self.reloadBkg.alpha = 0.0
                },
                               completion: { complete in
                                self.reloadBkg.isHidden = true
                })
            }
        }
    }
    
    
    @IBAction func search(_ sender: Any) {
        if let queryString = addressBar.text,
            !queryString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            
            let query = queryString.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            let address = "https://www.google.com/search?q=\(query)"
            
            if let myURL = URL(string: address) {
                let myRequest = URLRequest(url: myURL)
                webview.load(myRequest)
            }
        }
        addressBar.resignFirstResponder()
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == addressBar{
            lastAddressBarAttributeText = textField.attributedText
            textField.text = lastAddress
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField == addressBar, let attributed = lastAddressBarAttributeText{
            textField.attributedText = attributed
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addressBar{
            go(addressBar)
        }
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            progressBar.setProgress(Float(webview.estimatedProgress), animated: false)
        }
    }

//    @IBAction func goBack(_ sender: Any) {
//        if webview.canGoBack{
//            webview.goBack()
//        }
//    }
//    
//    @IBAction func goForward(_ sender: Any) {
//        if webview.canGoForward{
//            webview.goForward()
//        }
//    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressBar.isHidden = false
        progressBar.setProgress(Float(webView.estimatedProgress), animated: false)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        progressBar.setProgress(Float(webView.estimatedProgress), animated: false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let addressBarToShown = NSMutableAttributedString(string: "")
        var titleAvailable = false
        if !addressBar.isFocused{
            if let title = webview.title, !title.isEmpty{
                titleAvailable = true
                let titleString = NSAttributedString(string: title)
                addressBarToShown.append(titleString)
            }
            if let url = webview.url{
                lastAddress = url.absoluteString
                if titleAvailable{
                    let urlString = NSAttributedString(string: " - \(url.absoluteString)", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
                    addressBarToShown.append(urlString)
                } else {
                    let urlString = NSAttributedString(string: url.absoluteString, attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
                    addressBarToShown.append(urlString)
                }
            }
        }
        addressBar.attributedText = addressBarToShown
        
        progressBar.setProgress(Float(webView.estimatedProgress), animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.progressBar.isHidden = true
        }
        
    }
    
}

