//
//  ViewController.swift
//  CafeKioskApp
//
//  Created by ios on 2/3/26.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        label.text = "스파르타 카페"
        label.textColor = .black
        label.textAlignment = .center
        
        label.addSubview(label)
        
    }
}

