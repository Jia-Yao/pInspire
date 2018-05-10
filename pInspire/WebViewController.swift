//
//  WebViewController.swift
//  pInspire
//
//  Created by 臧晓雪 on 5/3/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import WebKit
import Firebase

class WebViewController: UIViewController, WKNavigationDelegate{

    //MARK: Properties
    
    @IBOutlet weak var webViewContainer: UIView!
    var actualWebView: WKWebView?
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var sources = [String]()
    var urls = [String]()
    var refPoll: DatabaseReference!
    
    override func loadView() {
        super.loadView()
     }
    
    @IBAction func tabIndexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if urls.count > 0{
                let url: URL = URL(string: urls[0])!
                self.actualWebView!.load(URLRequest(url: url))
            } else {
                let url: URL = URL(string: "https://google.com")!
                self.actualWebView!.load(URLRequest(url: url))
            }
        case 1:
            if urls.count > 1{
                let url: URL = URL(string: urls[1])!
                self.actualWebView!.load(URLRequest(url: url))
            } else {
                let url: URL = URL(string: "https://google.com")!
                self.actualWebView!.load(URLRequest(url: url))
            }
        case 2:
            if urls.count > 2{
                let url: URL = URL(string: urls[2])!
                self.actualWebView!.load(URLRequest(url: url))
            } else {
                let url: URL = URL(string: "https://google.com")!
                self.actualWebView!.load(URLRequest(url: url))
            }
        default:
            break;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Articles"
        self.actualWebView = WKWebView(frame: webViewContainer.bounds, configuration: WKWebViewConfiguration())
        self.actualWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webViewContainer.addSubview(self.actualWebView!)
        
        refPoll.observeSingleEvent(of: .value, with: { snapshot in
            self.sources.removeAll()
            self.urls.removeAll()
            for data in snapshot.children.allObjects as! [DataSnapshot] {
                let source = data.key
                let url = data.value as? String ?? "https://google.com"
                self.sources.append(source)
                self.urls.append(url)
            }
            if self.sources.count == 0{
                self.title = ""
                self.segmentedControl.isHidden = true
                self.actualWebView!.load(URLRequest(url: URL(string: "https://google.com")!))
            } else {
                self.actualWebView!.load(URLRequest(url: URL(string: self.urls[0])!))
                for i in 0..<self.sources.count{
                    self.segmentedControl.setTitle(self.sources[i], forSegmentAt: i)
                }
            }
        })
        
        // 2
        // let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        // toolbarItems = [refresh]
        // navigationController?.isToolbarHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //title = webView.title
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
