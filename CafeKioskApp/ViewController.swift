//
//  ViewController.swift
//  CafeKioskApp
//
//  Created by ios on 2/3/26.
//


 import UIKit
 import SnapKit

 final class ViewController: UIViewController {

     // MARK: - UI (Top)
     private let label = UILabel()

     private let categorySegment: UISegmentedControl = {
         let seg = UISegmentedControl(items: ["커피", "스무디", "디저트"])
         seg.selectedSegmentIndex = 0

         seg.setTitleTextAttributes([
             .foregroundColor: UIColor.white,
             .font: UIFont.systemFont(ofSize: 17, weight: .bold)
         ], for: .selected)

         seg.setTitleTextAttributes([
             .foregroundColor: UIColor.darkGray,
             .font: UIFont.systemFont(ofSize: 16, weight: .medium)
         ], for: .normal)

         seg.selectedSegmentTintColor = .orange
         seg.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
         return seg
     }()

     // MARK: - UI (Menu)
     private lazy var collectionView: UICollectionView = {
         let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
         cv.backgroundColor = .white
         cv.dataSource = self
         cv.delegate = self
         cv.register(MenuCell.self, forCellWithReuseIdentifier: MenuCell.id)
         return cv
     }()

     // MARK: - UI (Order)
     private let orderCountLabel: UILabel = {
         let lb = UILabel()
         lb.text = "총 주문내역 0개"
         lb.font = .systemFont(ofSize: 16, weight: .bold)
         lb.textColor = .black
         return lb
     }()

     private lazy var orderTableView: UITableView = {
         let tv = UITableView(frame: .zero, style: .plain)
         tv.dataSource = self
         tv.separatorStyle = .singleLine
         tv.tableFooterView = UIView()
         tv.register(OrderCell.self, forCellReuseIdentifier: OrderCell.id)
         tv.rowHeight = 64
         return tv
     }()

     // MARK: - Bottom Actions (취소/결제)
     private let cancelButton: UIButton = {
         let b = UIButton(type: .system)
         b.setTitle("취소하기", for: .normal)
         b.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
         b.setTitleColor(.white, for: .normal)
         b.backgroundColor = .black
         b.layer.cornerRadius = 12
         return b
     }()

     private let payButton: UIButton = {
         let b = UIButton(type: .system)
         b.setTitle("결제하기", for: .normal)
         b.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
         b.setTitleColor(.white, for: .normal)
         b.backgroundColor = .orange   //
         b.layer.cornerRadius = 12
         return b
     }()

     private lazy var bottomActionStack: UIStackView = {
         let sv = UIStackView(arrangedSubviews: [cancelButton, payButton])
         sv.axis = .horizontal
         sv.spacing = 12
         sv.distribution = .fillEqually
         return sv
     }()

     // MARK: - Data
     struct MenuItem {
         let name: String
         let imageName: String?
         let price: Int
     }

     struct OrderItem {
         let menu: MenuItem
         var quantity: Int
     }

     // ✅ 커피 4개만 (헤이즐넛/모카 제거)
     private let coffeeMenus: [MenuItem] = [
         .init(name: "에스프레소", imageName: "Espresso", price: 3000),
         .init(name: "아메리카노", imageName: "Americano", price: 3500),
         .init(name: "카페라떼", imageName: "Cafelatte", price: 4000),
         .init(name: "바닐라라떼", imageName: "Vanilalatte", price: 4500)
     ]

     private let smoothieMenus: [MenuItem] = [
         .init(name: "딸기 스무디", imageName: nil, price: 5000),
         .init(name: "망고 스무디", imageName: nil, price: 5200),
         .init(name: "블루베리 스무디", imageName: nil, price: 5200),
         .init(name: "요거트 스무디", imageName: nil, price: 4800)
     ]

     private let dessertMenus: [MenuItem] = [
         .init(name: "도넛", imageName: nil, price: 2500),
         .init(name: "치즈케이크", imageName: nil, price: 5500),
         .init(name: "마카롱", imageName: nil, price: 3000),
         .init(name: "쿠키", imageName: nil, price: 2000)
     ]

     private var currentMenus: [MenuItem] = []
     private var orderItems: [OrderItem] = []

     // MARK: - LifeCycle
     override func viewDidLoad() {
         super.viewDidLoad()

         currentMenus = coffeeMenus

         configureUI()
         configureCategoryBar()
         configureMenuCollectionView() // ✅ 메뉴는 위쪽에 “높이 제한”
         configureOrderArea()          // ✅ 주문 영역은 아래 + 버튼
         updateOrderCountLabel()
     }

     // MARK: - UI Setup
     private func configureUI() {
         view.backgroundColor = .white

         label.text = "영규 카페"
         label.textColor = .black
         label.font = UIFont.systemFont(ofSize: 20, weight: .bold)

         view.addSubview(label)
         label.snp.makeConstraints {
             $0.height.equalTo(50)
             $0.centerX.equalToSuperview()
             $0.top.equalToSuperview().offset(50)
         }
     }

     private func configureCategoryBar() {
         view.addSubview(categorySegment)
         categorySegment.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)

         categorySegment.snp.makeConstraints {
             $0.top.equalTo(label.snp.bottom).offset(12)
             $0.leading.trailing.equalToSuperview().inset(20)
             $0.height.equalTo(40)
         }
     }

     // ✅ 메뉴 컬렉션뷰: 화면 위쪽에서 “높이 제한”해서 주문영역 공간 확보
     private func configureMenuCollectionView() {
         view.addSubview(collectionView)

         collectionView.snp.makeConstraints {
             $0.top.equalTo(categorySegment.snp.bottom).offset(16)
             $0.leading.trailing.equalToSuperview().inset(20)
             $0.height.equalTo(360)  // ✅ 필요하면 300~420 사이로 조절
         }
     }

     // ✅ 주문 영역: 메뉴 아래에 배치 + 하단 버튼(취소/결제)
     private func configureOrderArea() {
         view.addSubview(orderCountLabel)
         view.addSubview(orderTableView)
         view.addSubview(bottomActionStack)

         orderCountLabel.snp.makeConstraints {
             $0.top.equalTo(collectionView.snp.bottom).offset(12)
             $0.leading.trailing.equalToSuperview().inset(20)
         }

         bottomActionStack.snp.makeConstraints {
             $0.leading.trailing.equalToSuperview().inset(20)
             $0.bottom.equalToSuperview().inset(20)
             $0.height.equalTo(56)
         }

         orderTableView.snp.makeConstraints {
             $0.top.equalTo(orderCountLabel.snp.bottom).offset(8)
             $0.leading.trailing.equalToSuperview().inset(20)
             $0.bottom.equalTo(bottomActionStack.snp.top).offset(-10)
         }

         cancelButton.addTarget(self, action: #selector(didTapCancelAll), for: .touchUpInside)
         payButton.addTarget(self, action: #selector(didTapPayAll), for: .touchUpInside)
     }

     // MARK: - Compositional Layout (2열 그리드)
     private func makeLayout() -> UICollectionViewLayout {

         let itemSize = NSCollectionLayoutSize(
             widthDimension: .fractionalWidth(0.5),
             heightDimension: .fractionalHeight(1.0)
         )
         let item = NSCollectionLayoutItem(layoutSize: itemSize)

         let groupHeight: CGFloat = 160
         let groupSize = NSCollectionLayoutSize(
             widthDimension: .fractionalWidth(1.0),
             heightDimension: .absolute(groupHeight)
         )
         let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
         group.interItemSpacing = .fixed(12)

         let section = NSCollectionLayoutSection(group: group)
         section.interGroupSpacing = 12

         return UICollectionViewCompositionalLayout(section: section)
     }

     // MARK: - Actions
     @objc private func categoryChanged() {
         switch categorySegment.selectedSegmentIndex {
         case 0:
             currentMenus = coffeeMenus
         case 1:
             currentMenus = smoothieMenus
         case 2:
             currentMenus = dessertMenus
         default:
             break
         }
         collectionView.reloadData()
     }

     private func updateOrderCountLabel() {
         let total = orderItems.reduce(0) { $0 + $1.quantity }
         orderCountLabel.text = "총 주문내역 \(total)개"

         // ✅ 주문 없으면 버튼 비활성화
         let hasOrder = total > 0
         cancelButton.isEnabled = hasOrder
         payButton.isEnabled = hasOrder
         cancelButton.alpha = hasOrder ? 1.0 : 0.4
         payButton.alpha = hasOrder ? 1.0 : 0.4
     }

     private func addMenuToOrder(_ menu: MenuItem) {
         if let idx = orderItems.firstIndex(where: { $0.menu.name == menu.name }) {
             orderItems[idx].quantity += 1
         } else {
             orderItems.append(OrderItem(menu: menu, quantity: 1))
         }
         updateOrderCountLabel()
         orderTableView.reloadData()
     }

     private func increaseQuantity(at row: Int) {
         guard orderItems.indices.contains(row) else { return }
         orderItems[row].quantity += 1
         updateOrderCountLabel()
         orderTableView.reloadData()
     }

     private func decreaseQuantity(at row: Int) {
         guard orderItems.indices.contains(row) else { return }
         orderItems[row].quantity -= 1
         if orderItems[row].quantity <= 0 {
             orderItems.remove(at: row)
         }
         updateOrderCountLabel()
         orderTableView.reloadData()
     }

     // MARK: - Bottom Button Actions
     @objc private func didTapCancelAll() {
         guard !orderItems.isEmpty else { return }
         orderItems.removeAll()
         updateOrderCountLabel()
         orderTableView.reloadData()
     }

     @objc private func didTapPayAll() {
         guard !orderItems.isEmpty else { return }

         let totalPrice = orderItems.reduce(0) { partial, item in
             partial + (item.menu.price * item.quantity)
         }

         let alert = UIAlertController(
             title: "결제 완료",
             message: "총 \(totalPrice)원 결제되었습니다.",
             preferredStyle: .alert
         )
         alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
             self?.orderItems.removeAll()
             self?.updateOrderCountLabel()
             self?.orderTableView.reloadData()
         })

         present(alert, animated: true)
     }
 }

 // MARK: - CollectionView DataSource / Delegate
 extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return currentMenus.count
     }

     func collectionView(_ collectionView: UICollectionView,
                         cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCell.id, for: indexPath) as? MenuCell else {
             return UICollectionViewCell()
         }
         cell.configure(item: currentMenus[indexPath.item])
         return cell
     }

     // ✅ 메뉴(셀) 눌렀을 때 주문내역에 추가
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let menu = currentMenus[indexPath.item]
         addMenuToOrder(menu)
     }
 }

 // MARK: - TableView DataSource
 extension ViewController: UITableViewDataSource {

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return orderItems.count
     }

     func tableView(_ tableView: UITableView,
                    cellForRowAt indexPath: IndexPath) -> UITableViewCell {

         guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.id, for: indexPath) as? OrderCell else {
             return UITableViewCell()
         }

         let item = orderItems[indexPath.row]

         cell.configure(
             name: item.menu.name,
             price: item.menu.price,
             quantity: item.quantity
         )

         // ✅ + / - 버튼 눌렀을 때 ViewController로 다시 알려주기 (클로저)
         cell.onTapPlus = { [weak self] in
             self?.increaseQuantity(at: indexPath.row)
         }
         cell.onTapMinus = { [weak self] in
             self?.decreaseQuantity(at: indexPath.row)
         }

         return cell
     }
 }

 // MARK: - Menu Cell (CollectionView)
 final class MenuCell: UICollectionViewCell {

     static let id = "MenuCell"

     private let imageView = UIImageView()
     private let titleLabel = UILabel()
     private let priceLabel = UILabel()

     override init(frame: CGRect) {
         super.init(frame: frame)

         contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
         contentView.layer.cornerRadius = 12
         contentView.clipsToBounds = true

         imageView.contentMode = .scaleAspectFit
         imageView.clipsToBounds = true

         titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
         titleLabel.textColor = .black
         titleLabel.textAlignment = .center
         titleLabel.numberOfLines = 2

         priceLabel.font = .systemFont(ofSize: 14, weight: .bold)
         priceLabel.textColor = .darkGray
         priceLabel.textAlignment = .center

         contentView.addSubview(imageView)
         contentView.addSubview(titleLabel)
         contentView.addSubview(priceLabel)

         imageView.snp.makeConstraints {
             $0.top.equalToSuperview().offset(10)
             $0.leading.trailing.equalToSuperview().inset(10)
             $0.height.equalToSuperview().multipliedBy(0.6)
         }

         titleLabel.snp.makeConstraints {
             $0.top.equalTo(imageView.snp.bottom).offset(6)
             $0.leading.trailing.equalToSuperview().inset(8)
         }

         priceLabel.snp.makeConstraints {
             $0.top.equalTo(titleLabel.snp.bottom).offset(4)
             $0.leading.trailing.equalToSuperview().inset(8)
             $0.bottom.lessThanOrEqualToSuperview().inset(8)
         }
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }

     func configure(item: ViewController.MenuItem) {
         titleLabel.text = item.name
         priceLabel.text = "₩\(item.price)"

         if let imageName = item.imageName,
            let img = UIImage(named: imageName) {
             imageView.image = img
         } else {
             imageView.image = UIImage(systemName: "photo")
         }
     }
 }

 // MARK: - Order Cell (TableView)
 final class OrderCell: UITableViewCell {

     static let id = "OrderCell"

     private let nameLabel = UILabel()
     private let priceLabel = UILabel()
     private let minusButton = UIButton(type: .system)
     private let qtyLabel = UILabel()
     private let plusButton = UIButton(type: .system)

     var onTapPlus: (() -> Void)?
     var onTapMinus: (() -> Void)?

     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)

         selectionStyle = .none

         nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
         nameLabel.textColor = .black

         priceLabel.font = .systemFont(ofSize: 13, weight: .medium)
         priceLabel.textColor = .darkGray

         minusButton.setTitle("−", for: .normal)
         minusButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)

         plusButton.setTitle("+", for: .normal)
         plusButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)

         qtyLabel.font = .systemFont(ofSize: 15, weight: .bold)
         qtyLabel.textAlignment = .center
         qtyLabel.textColor = .black

         contentView.addSubview(nameLabel)
         contentView.addSubview(priceLabel)
         contentView.addSubview(minusButton)
         contentView.addSubview(qtyLabel)
         contentView.addSubview(plusButton)

         nameLabel.snp.makeConstraints {
             $0.leading.equalToSuperview().offset(12)
             $0.top.equalToSuperview().offset(10)
             $0.trailing.lessThanOrEqualTo(minusButton.snp.leading).offset(-8)
         }

         priceLabel.snp.makeConstraints {
             $0.leading.equalTo(nameLabel)
             $0.top.equalTo(nameLabel.snp.bottom).offset(2)
             $0.bottom.equalToSuperview().inset(10)
         }

         plusButton.snp.makeConstraints {
             $0.trailing.equalToSuperview().inset(12)
             $0.centerY.equalToSuperview()
             $0.width.equalTo(32)
             $0.height.equalTo(32)
         }

         qtyLabel.snp.makeConstraints {
             $0.trailing.equalTo(plusButton.snp.leading).offset(-6)
             $0.centerY.equalToSuperview()
             $0.width.equalTo(28)
         }

         minusButton.snp.makeConstraints {
             $0.trailing.equalTo(qtyLabel.snp.leading).offset(-6)
             $0.centerY.equalToSuperview()
             $0.width.equalTo(32)
             $0.height.equalTo(32)
         }

         minusButton.addTarget(self, action: #selector(didTapMinus), for: .touchUpInside)
         plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }

     func configure(name: String, price: Int, quantity: Int) {
         nameLabel.text = name
         priceLabel.text = "₩\(price)"
         qtyLabel.text = "\(quantity)"
     }

     @objc private func didTapPlus() { onTapPlus?() }
     @objc private func didTapMinus() { onTapMinus?() }
 }


