//
//  ViewController.swift
//  SwiftWebSocketClient
//
//  Created by unchain on 2023/03/12.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var stockValueLabel: NSTextField!

    let webSocket = SwiftWebSocketClient.shared
    override func viewDidLoad() {
        super.viewDidLoad()

        webSocket.subscribeToService { stockValue in
            guard let stockValue = stockValue else {
                return
            }

            DispatchQueue.main.async {
                self.stockValueLabel.stringValue = "Client Received " + stockValue
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}
