//
//  ViewController.swift
//  ChatTableView
//
//  Created by Matic Oblak on 2/23/17.
//  Copyright © 2017 Kamino. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction private func goToChatPressed(_ sender: Any) {
        
        present(ChatViewController.instanceFromStoryboard(), animated: true, completion: nil)
        
    }

}

