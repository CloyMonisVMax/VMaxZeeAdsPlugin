//
//  ViewController.swift
//  VMaxZeeAdsPlugin
//
//  Created by CloyMonisVMax on 09/25/2021.
//  Copyright (c) 2021 CloyMonisVMax. All rights reserved.
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
    
    @IBAction func actionRedirect(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController{
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}

