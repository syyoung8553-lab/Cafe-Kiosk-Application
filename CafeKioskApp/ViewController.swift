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
        
        ConfigureUI()
    }


    func ConfigureUI(){
        view.backgroundColor = .white
        label.text = "🍩스파르타 카페"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        view.addSubview(label)
        
        label.snp.makeConstraints{
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(50)
            
        }
    }
    
    
}

