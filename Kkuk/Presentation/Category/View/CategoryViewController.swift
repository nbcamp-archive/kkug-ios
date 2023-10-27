//
//  CategoryViewController.swift
//  Kkuk
//
//  Created by Yujin Kim on 2023-10-16.
//

import SnapKit
import UIKit

class CategoryViewController: BaseUIViewController {
    private var category: [Category] = []
    private var categoryManager = RealmCategoryManager.shared

    private let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.register(AddCategoryCollectionViewCell.self, forCellWithReuseIdentifier: "AddCategoryCollectionViewCell")
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 27, bottom: 10, right: 27)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func setUI() {
        view.addSubview(categoryCollectionView)
        category = categoryManager.read()
    }

    override func setLayout() {
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    override func setDelegate() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
    }

    override func addTarget() {}
}

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath[1]
        if index == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCategoryCollectionViewCell",
                                                                for: indexPath) as? AddCategoryCollectionViewCell else { return UICollectionViewCell() }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell",
                                                                for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
            let category = category[indexPath.item - 1]
            cell.configure(category: category)
            cell.delegate = self
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath[1]
        if index == 0 {
            let customVC = AddCategoryViewController()
            customVC.delegate = self
            let navController = UINavigationController(rootViewController: customVC)
            present(navController, animated: true, completion: nil)
        } else {
            let customVC = CategoryInnerViewController()
            customVC.modalPresentationStyle = .fullScreen
            let category = category[indexPath.item - 1]
            customVC.configure(category: category)
            navigationController?.pushViewController(customVC, animated: true)
        }
    }
}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        let itemsPerRow: CGFloat = 2.2
        let widthPadding = sectionInsets.left * itemsPerRow
        let itemsPerColumn: CGFloat = 3.5
        let heightPadding = sectionInsets.top * itemsPerColumn
        let cellWidth = (width - widthPadding) / itemsPerRow
        let cellHeight = (height - heightPadding) / itemsPerColumn

        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension CategoryViewController: AddCategoryViewControllerDelegate {
    func reloadCollectionView() {
        category = categoryManager.read()
        categoryCollectionView.reloadData()
    }
}

extension CategoryViewController: CategoryCollectionViewCellDelegate {
    func deleteCollectionViewCell() {
        category = categoryManager.read()
        categoryCollectionView.reloadData()
    }
}
