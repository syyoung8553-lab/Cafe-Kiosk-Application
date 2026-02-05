//
//  ViewController.swift
//  KioskApp
//
//  ✅ 포함 기능
//  - 상단 SegmentedControl(커피/스무디/디저트)
//  - 메뉴 2열 CollectionView
//  - 장바구니(비었을 때 안내문 / 담겼을 때 TableView)
//  - 총 주문금액 표시
//  - 취소하기(확인 Alert 후 전체 삭제)
//  - 결제하기(결제 완료 Alert 후 전체 삭제)
//  - OrderCell 등록 오류 해결: OrderCell은 반드시 UITableViewCell 상속 + static id 제공
//

import UIKit
import SnapKit

final class ViewController: UIViewController {

    // MARK: - Top
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "🏡 스파르타 카페"
        lb.font = .systemFont(ofSize: 24, weight: .bold)
        lb.textAlignment = .center
        return lb
    }()

    private let categorySegment: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["커피", "스무디", "디저트"])
        seg.selectedSegmentIndex = 1   // 필요하면 0으로 바꾸기

        seg.selectedSegmentTintColor = .systemOrange
        seg.backgroundColor = UIColor(white: 0.88, alpha: 1.0)

        seg.setTitleTextAttributes([
            .foregroundColor: UIColor.darkGray,
            .font: UIFont.systemFont(ofSize: 17, weight: .medium)
        ], for: .normal)

        seg.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ], for: .selected)

        seg.layer.cornerRadius = 26
        seg.clipsToBounds = true
        return seg
    }()

    // MARK: - Menu (Collection)
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.register(MenuCell.self, forCellWithReuseIdentifier: MenuCell.id)
        return cv
    }()

    // MARK: - Cart (Container + Table)
    private let cartContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    private let cartTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "장바구니"
        lb.font = .systemFont(ofSize: 18, weight: .bold)
        return lb
    }()

    private let cartCountLabel: UILabel = {
        let lb = UILabel()
        lb.text = "총 주문내역 0개"
        lb.font = .systemFont(ofSize: 16, weight: .semibold)
        lb.textColor = .darkGray
        lb.textAlignment = .right
        return lb
    }()

    private let cartEmptyLabel: UILabel = {
        let lb = UILabel()
        lb.text = "장바구니가 비어있습니다"
        lb.font = .systemFont(ofSize: 16, weight: .medium)
        lb.textColor = .darkGray
        lb.textAlignment = .center
        return lb
    }()

    // ✅ 여기에서 오류났던 register는, OrderCell이 UITableViewCell 상속 + id가 있어야 정상
    private lazy var orderTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.dataSource = self
        tv.separatorStyle = .singleLine
        tv.tableFooterView = UIView()
        tv.register(OrderCell.self, forCellReuseIdentifier: OrderCell.id) // ✅ 정상
        tv.rowHeight = 70
        tv.backgroundColor = .clear
        tv.showsVerticalScrollIndicator = true
        return tv
    }()

    // MARK: - Bottom (Total + Buttons) ✅ 버튼은 맨 밑
    private let bottomContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let totalTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "총 주문금액"
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.textColor = .black
        return lb
    }()

    private let totalValueLabel: UILabel = {
        let lb = UILabel()
        lb.text = "0원"
        lb.font = .systemFont(ofSize: 30, weight: .heavy)
        lb.textColor = .black
        lb.textAlignment = .right
        return lb
    }()

    private let cancelButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("취소하기", for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        bt.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        bt.setTitleColor(.darkGray, for: .normal)
        bt.layer.cornerRadius = 16
        return bt
    }()

    private let payButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("결제하기", for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        bt.backgroundColor = .systemOrange
        bt.setTitleColor(.white, for: .normal)
        bt.layer.cornerRadius = 16
        return bt
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

    private let coffeeMenus: [MenuItem] = [
        .init(name: "에스프레소", imageName: nil, price: 3000),
        .init(name: "아메리카노", imageName: nil, price: 3500),
        .init(name: "카페라떼", imageName: nil, price: 4000),
        .init(name: "바닐라라떼", imageName: nil, price: 4500)
    ]

    private let smoothieMenus: [MenuItem] = [
        .init(name: "딸기 요거트 스무디", imageName: "strawberry_yogurt_smoothie", price: 4500),
        .init(name: "망고 요거트 스무디", imageName: "manggo_yogurt_smoothie", price: 4500),
        .init(name: "딸기 스무디", imageName: "strawberry_smoothie", price: 4000),
        .init(name: "망고 스무디", imageName: "manggo_smoothie", price: 4000)
    ]

    private let dessertMenus: [MenuItem] = [
        .init(name: "두바이 쫀득 쿠키", imageName: "dubai_cookie", price: 8000),
        .init(name: "딸기 조각 케이크", imageName: "strawberry_cake", price: 5500),
        .init(name: "초코 마카롱", imageName: "choco_macaron", price: 3000),
        .init(name: "햄치즈 샌드위치", imageName: "hamcheese_sandwich", price: 2000)
    ]

    private var currentMenus: [MenuItem] = []
    private var orderItems: [OrderItem] = []

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        currentMenus = menus(for: categorySegment.selectedSegmentIndex)

        configureUI()
        configureCategoryBar()
        configureMenuCollectionView()

        // ✅ bottom 먼저(맨 밑 고정) -> cart가 그 위까지 올라오게
        configureBottomArea()
        configureCartArea()

        categorySegment.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        payButton.addTarget(self, action: #selector(didTapPay), for: .touchUpInside)

        updateCartUI()
    }

    // MARK: - UI Setup
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(34)
        }
    }

    private func configureCategoryBar() {
        view.addSubview(categorySegment)
        categorySegment.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
    }

    private func configureMenuCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(categorySegment.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(380).priority(750)
        }
    }

    // ✅ 총 주문금액(윗줄) + 버튼(아랫줄) => bottomContainer는 safeArea bottom에 고정
    private func configureBottomArea() {
        view.addSubview(bottomContainer)

        bottomContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12) // ✅ 맨 밑
        }

        bottomContainer.addSubview(totalTitleLabel)
        bottomContainer.addSubview(totalValueLabel)
        bottomContainer.addSubview(cancelButton)
        bottomContainer.addSubview(payButton)

        totalTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        totalValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(totalTitleLabel)
            $0.trailing.equalToSuperview()
        }

        cancelButton.snp.makeConstraints {
            $0.top.equalTo(totalTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
            $0.height.equalTo(58)
            $0.trailing.equalTo(bottomContainer.snp.centerX).offset(-8)
            $0.bottom.equalToSuperview() // ✅ bottomContainer 바닥
        }

        payButton.snp.makeConstraints {
            $0.top.equalTo(cancelButton)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(58)
            $0.leading.equalTo(bottomContainer.snp.centerX).offset(8)
            $0.bottom.equalToSuperview()
        }
    }

    // ✅ cart는 bottomContainer 위까지
    private func configureCartArea() {
        view.addSubview(cartContainer)

        cartContainer.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(bottomContainer.snp.top).offset(-14)
        }

        cartContainer.addSubview(cartTitleLabel)
        cartContainer.addSubview(cartCountLabel)
        cartContainer.addSubview(cartEmptyLabel)
        cartContainer.addSubview(orderTableView)

        cartTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
        }

        cartCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(cartTitleLabel)
            $0.trailing.equalToSuperview().inset(16)
        }

        orderTableView.snp.makeConstraints {
            $0.top.equalTo(cartTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        cartEmptyLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }

    // MARK: - Layout (2열)
    private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupHeight: CGFloat = 175
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(groupHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(14)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 14

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Helpers
    private func menus(for index: Int) -> [MenuItem] {
        switch index {
        case 0: return coffeeMenus
        case 1: return smoothieMenus
        case 2: return dessertMenus
        default: return coffeeMenus
        }
    }

    private func clearOrder() {
        orderItems.removeAll()
        orderTableView.reloadData()
        updateCartUI()
    }

    // MARK: - Actions
    @objc private func categoryChanged() {
        currentMenus = menus(for: categorySegment.selectedSegmentIndex)
        collectionView.reloadData()
    }

    // ✅ 취소하기: 확인 Alert 띄우고 "삭제" 눌렀을 때만 삭제
    @objc private func didTapCancel() {
        guard !orderItems.isEmpty else { return }

        let alert = UIAlertController(
            title: "주문 취소",
            message: "주문 내역을 모두 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "아니오", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.clearOrder()
        })
        present(alert, animated: true)
    }

    @objc private func didTapPay() {
        guard !orderItems.isEmpty else { return }

        let total = totalPrice()
        let alert = UIAlertController(
            title: "결제 완료",
            message: "결제금액: \(formatWon(total))\n주문이 완료되었습니다 ☕️",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.clearOrder()
        })
        present(alert, animated: true)
    }

    // MARK: - Order Logic
    private func addMenuToOrder(_ menu: MenuItem) {
        if let idx = orderItems.firstIndex(where: { $0.menu.name == menu.name }) {
            orderItems[idx].quantity += 1
        } else {
            orderItems.append(OrderItem(menu: menu, quantity: 1))
        }
        orderTableView.reloadData()
        updateCartUI()
    }

    private func increaseQuantity(at row: Int) {
        guard orderItems.indices.contains(row) else { return }
        orderItems[row].quantity += 1
        orderTableView.reloadData()
        updateCartUI()
    }

    private func decreaseQuantity(at row: Int) {
        guard orderItems.indices.contains(row) else { return }
        orderItems[row].quantity -= 1
        if orderItems[row].quantity <= 0 {
            orderItems.remove(at: row)
        }
        orderTableView.reloadData()
        updateCartUI()
    }

    // MARK: - UI Update
    private func updateCartUI() {
        let qtyTotal = totalQuantity()
        cartCountLabel.text = "총 주문내역 \(qtyTotal)개"

        let isEmpty = orderItems.isEmpty
        cartEmptyLabel.isHidden = !isEmpty
        orderTableView.isHidden = isEmpty

        let total = totalPrice()
        totalValueLabel.text = formatWon(total)

        payButton.isEnabled = !isEmpty
        payButton.alpha = isEmpty ? 0.45 : 1.0
    }

    private func totalQuantity() -> Int {
        orderItems.reduce(0) { $0 + $1.quantity }
    }

    private func totalPrice() -> Int {
        orderItems.reduce(0) { $0 + ($1.menu.price * $1.quantity) }
    }

    private func formatWon(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let str = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(str)원"
    }
}

// MARK: - CollectionView
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentMenus.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCell.id, for: indexPath) as? MenuCell else {
            return UICollectionViewCell()
        }
        cell.configure(item: currentMenus[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addMenuToOrder(currentMenus[indexPath.item])
    }
}

// MARK: - TableView
extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orderItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.id, for: indexPath) as? OrderCell else {
            return UITableViewCell()
        }

        let item = orderItems[indexPath.row]
        cell.configure(name: item.menu.name, price: item.menu.price, quantity: item.quantity)

        // ✅ indexPath 캡처 이슈 방지: row를 고정
        let row = indexPath.row
        cell.onTapPlus = { [weak self] in self?.increaseQuantity(at: row) }
        cell.onTapMinus = { [weak self] in self?.decreaseQuantity(at: row) }

        return cell
    }
}

// MARK: - Menu Cell
final class MenuCell: UICollectionViewCell {

    static let id = "MenuCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        priceLabel.font = .systemFont(ofSize: 18, weight: .bold)
        priceLabel.textColor = .darkGray
        priceLabel.textAlignment = .center

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)

        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.trailing.equalToSuperview().inset(14)
            $0.height.equalToSuperview().multipliedBy(0.58)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(10)
        }

        priceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(item: ViewController.MenuItem) {
        titleLabel.text = item.name
        priceLabel.text = formatWon(item.price)

        if let imageName = item.imageName, let img = UIImage(named: imageName) {
            imageView.image = img
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }

    private func formatWon(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let str = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(str)원"
    }
}

// MARK: - Order Cell  ✅ 반드시 UITableViewCell 상속
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
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .black

        priceLabel.font = .systemFont(ofSize: 16, weight: .medium)
        priceLabel.textColor = .darkGray

        minusButton.setTitle("−", for: .normal)
        minusButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)

        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)

        qtyLabel.font = .systemFont(ofSize: 18, weight: .bold)
        qtyLabel.textAlignment = .center
        qtyLabel.textColor = .black

        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(minusButton)
        contentView.addSubview(qtyLabel)
        contentView.addSubview(plusButton)

        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(12)
            $0.trailing.lessThanOrEqualTo(minusButton.snp.leading).offset(-10)
        }

        priceLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(6)
            $0.bottom.equalToSuperview().inset(12)
        }

        plusButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(34)
        }

        qtyLabel.snp.makeConstraints {
            $0.trailing.equalTo(plusButton.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(30)
        }

        minusButton.snp.makeConstraints {
            $0.trailing.equalTo(qtyLabel.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(34)
        }

        minusButton.addTarget(self, action: #selector(didTapMinus), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onTapPlus = nil
        onTapMinus = nil
    }

    func configure(name: String, price: Int, quantity: Int) {
        nameLabel.text = name
        priceLabel.text = formatWon(price)
        qtyLabel.text = "\(quantity)"
    }

    private func formatWon(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let str = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(str)원"
    }

    @objc private func didTapPlus() { onTapPlus?() }
    @objc private func didTapMinus() { onTapMinus?() }
}




