//
//  readMoreViewController.swift
//  pInspire
//
//  Created by 臧晓雪 on 5/3/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit

class readMoreViewController: UIViewController {
    
    // @IBOutlet weak var webViewTutorial: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let url = URL(string: "https://www.bideawee.org/")
        if let unwrappedURL = url {
            
            let request = URLRequest(url: unwrappedURL)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if error == nil {
                    
                    self.webViewTutorial.loadRequest(request)
                    
                } else {
                    print("ERROR: \(String(describing: error))")
                }
            }
            
            task.resume()
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
