//
//  ViewController.swift
//  CafeKioskApp
//
//  Created by ios on 2/3/26.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private let titleLabel = UILabel() // 스파르타 카페의 라벨
    private let menuStackView = UIStackView() // 메뉴 화면 뷰
    
    // 현재 선택된 메뉴.
    private var currentMenu: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        makeMenuStackView()
        
        currentMenu = Category.smoothie_Menu
        showMenu()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        // 스파르타 카페의 라벨 속성.
        titleLabel.text = "🏡 스파르타 카페"
        titleLabel.font = .boldSystemFont(ofSize: 23)
        titleLabel.textAlignment = .center
        
        // 스파르타 카페의 제약 조건.
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.centerX.equalToSuperview()
        }
        
        // MARK: - 상단 메뉴 카테고리 구현.
        let categoryButton = ["커피☕️", "스무디🥤", "디저트🍰"]
        let buttons = categoryButton.map { makeButton(title: $0) }
        
        // 카테고리 StackView 속성.
        let categoryStackView = UIStackView(arrangedSubviews: buttons)
        
        categoryStackView.axis = .horizontal
        categoryStackView.spacing = 20
        categoryStackView.distribution = .fillEqually
        
        // 카테고리 StackView의 제약 조건
        view.addSubview(categoryStackView)
        categoryStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(36)
            $0.height.equalTo(44)
        }
    }
    
    // 카테고리 버튼의 속성.
    private func makeButton(title: String) -> UIButton {
        
        let button = UIButton()
        
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor(red: 255/255, green: 150/255, blue: 0/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    // 카테고리 버튼이 클릭되었을 때.
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        
        guard let title = sender.currentTitle else { return }
        
        switch title {
        case "커피☕️": // 커피 버튼 클릭했을 때.
            currentMenu = Category.coffee_Menu
        case "스무디🥤": // 스무디 버튼 클릭했을 때.
            currentMenu = Category.smoothie_Menu
        case "디저트🍰": // 디저트 버튼 클릭했을 때.
            currentMenu = Category.dessert_Menu
        default:
            break
        }
        
        showMenu()
    }
    
    // MARK: - 메뉴 화면 구현
    private func makeMenuStackView() {
        
        // 메뉴 화면 StackView의 속성.
        menuStackView.axis = .vertical
        menuStackView.spacing = 16
        menuStackView.distribution = .fillEqually
        
        // 메뉴 화면 StackView의 제약 조건.
        view.addSubview(menuStackView)
        menuStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(400)
        }
    }
    
    //  메뉴 화면의 UI 구성.
    private func showMenu() {
        
        menuStackView.arrangedSubviews.forEach { // menuStackView 안에 있던 기존 메뉴 뷰들을 전부 제거해서 화면을 초기화하는 코드.
            $0.removeFromSuperview()
        }
        
        let displayMenu = Array(currentMenu.prefix(4)) // 현재 메뉴 배열에서 앞에서부터 최대 4개만 잘라서 화면에 쓰기 좋은 [Category] 배열로 만듬.
        
        // 메뉴를 2줄로 만듬.
        for row in 0..<2 {
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal // 수평(가로) 축.
            horizontalStackView.spacing = 16 // 스택 뷰 안에 들어있는 뷰들의 거리 16 설정.
            horizontalStackView.distribution = .fillEqually // 분배, 스택 뷰 내부의 사이즈 분배에 관한 설정. fillEqually를 선택하면 뷰들의 사이즈가 동일하게 맞춰진다.
            
            // 한 줄에 메뉴 2개씩 만듬.
            for col in 0..<2 {
                let index = row * 2 + col // 2×2 그리드에서 실제 메뉴 배열의 인덱스 계산.
                if index >= displayMenu.count { continue } // 메뉴가 4개 미만일 경우 에러 방지하고 넘어감
                
                let menuView = makeMenuView(displayMenu[index]) // 해당 인덱스의 메뉴 데이터를 이용해 메뉴 카드 UI 생성.
                horizontalStackView.addArrangedSubview(menuView) // 만든 메뉴 카드를 가로 스택뷰에 추가
            }
            
            menuStackView.addArrangedSubview(horizontalStackView) // 완성된 한 줄(2개 메뉴)을 세로 스택뷰에 추가.
        }
    }
    
    // 메뉴 뷰안에 이미지, 이름, 가격의 속성.
    private func makeMenuView(_ menu: Category) -> UIView {

        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 12

        // 이미지 컨테이너 크기 통일.
        let imageContainer = UIView()

        let imageView = UIImageView()
        imageView.image = UIImage(named: menu.image)
        imageView.contentMode = .scaleAspectFit

        imageContainer.addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }

        // 이미지 영역 높이 고정.
        imageContainer.snp.makeConstraints {
            $0.height.equalTo(120)
        }
        
        // 메뉴의 이름 설정.
        let nameLabel = UILabel()
        nameLabel.text = menu.menu
        nameLabel.font = .boldSystemFont(ofSize: 14)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        
        // 메뉴의 가격 설정.
        let priceLabel = UILabel()
        priceLabel.text = "\(menu.price)원"
        priceLabel.font = .systemFont(ofSize: 13)
        priceLabel.textColor = .darkGray
        priceLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [
            imageContainer,
            nameLabel,
            priceLabel
        ])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill

        container.addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }

        return container
    }


}



