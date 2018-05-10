//
//  WebViewController.swift
//  pInspire
//
//  Created by 臧晓雪 on 5/3/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1
        let url: URL = URL(string: (urlString ?? "")) ?? URL(string: "https://google.com")!
        webView.load(URLRequest(url: url))
        // 2
        // let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        // toolbarItems = [refresh]
        // navigationController?.isToolbarHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
