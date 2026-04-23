//
//  ViewController.swift
//  testkit
//
//  Created by electrozone on 3/26/26.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var lblHello: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lblHello.text = "안녕하세요!"
    }

    @IBAction func btnAction(_ sender: UIButton) {
        if lblHello.text == "안녕하세요!"{
            lblHello.text = "반갑습니다!"
        }else{
            lblHello.text = "안녕하세요!"
        }
    }
    
}

