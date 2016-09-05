//
//  ViewController.swift
//  TestServer
//
//  Created by Brennan Stehling on 9/4/16.
//  Copyright © 2016 SmallSharpTools LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var runRequestButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!

    let requestor = Requestor()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        statusLabel.text = nil
        requestor.isDebugging = true
    }

    @IBAction func runRequestButtonTapped(sender: AnyObject) {
        runRequest()
    }

    internal func runRequest() {
        debugPrint("Running request")

        requestor.request(.GET, baseURL: "https://httpbin.org", path: "/get", params: nil) { (response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if let response = response {
                    debugPrint("Response: \(response)")
                    self.statusLabel.text = "Success"
                }
                else if let error = error {
                    debugPrint("Error: \(error.localizedDescription)")
                    self.statusLabel.text = "Failure"
                }
            }
        }
    }

}
