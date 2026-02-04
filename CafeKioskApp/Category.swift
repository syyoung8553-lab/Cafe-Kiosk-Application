//
//  Category.swift
//  CafeKioskApp
//
//  Created by 이정인 on 2/3/26.
//

import Foundation

struct Category {
    
    let image: String // 이미지.
    let menu: String // 메뉴.
    let price: String // 가격.
}

extension Category {
    
    static let allArray = coffee_Menu + smoothie_Menu + dessert_Menu
    
    static let coffee_Menu = [
        Category(image: "espresso", menu: "에스프레소", price: "3,500"),
        Category(image: "amelikano", menu: "아메리카노", price: "3,300"),
        Category(image: "cafe latte", menu: "카페 라떼", price: "3,700"),
        Category(image: "banilla latte", menu: "바닐라 라떼", price: "4,200"),
        Category(image: "Hazelnut Latte", menu: "헤이즐넛 라떼", price: "4,500"),
        Category(image: "cafemoca", menu: "카페 모카", price: "3,900"),
    ]
    
    static let smoothie_Menu = [
        Category(image: "kiwi_smoothie", menu: "키위 스무디", price: "4,500"),
        Category(image: "manggo_smoothie", menu: "망고 스무디", price: "5,000"),
        Category(image: "manggo_yogurt_smoothie", menu: "망고 요거트 스무디", price: "5,700"),
        Category(image: "orange_smoothie", menu: "오렌지 스무디", price: "5,300"),
        Category(image: "strawberry_smoothie", menu: "딸기 스무디", price: "5,500"),
        Category(image: "strawberry_yogurt_smoothie", menu: "딸기 요거트 스무디", price: "6,300"),
    ]
    
    static let dessert_Menu = [
        Category(image: "Dubai Chewy Cookies", menu: "두바이 쫀득 쿠키", price: "8,000"),
        Category(image: "Strawberry Cake", menu: "딸기 조각 케이크", price: "7,500"),
        Category(image: "Crople", menu: "크로플", price: "4,500"),
        Category(image: "Ham Cheese Sandwich", menu: "햄치즈 샌드위치", price: "4,000"),
        Category(image: "Honey Butter Bread", menu: "허니 버터브레드", price: "6,000"),
        Category(image: "Chocolate Macaron", menu: "초코 마카롱", price: "3,300"),
        
    ]
    
}
