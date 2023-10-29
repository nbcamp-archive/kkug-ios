//
//  SearchContentViewController.swift
//  Kkuk
//
//  Created by Yujin Kim on 2023-10-16.
//

import UIKit

class SearchContentViewController: BaseUIViewController {
    
    var contentList: [Content] = []
    
    let recentSearchContentViewController = RecentSearchContentViewController()
    let recenteSearchManager = RecentSearchManager()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색어를 입력하세요"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.black.cgColor
            textField.layer.cornerRadius = 12.0
          }
        
        return searchBar
    }()
    
    private lazy var contentTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "ContentTableViewCell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    private lazy var noContentLabel: UILabel = {
        let label = UILabel()
        label.text = "아카이브가 없습니다"
        label.font = .subtitle2
        label.textColor = .text1
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isHidden = !contentList.isEmpty
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.addSubview(recentSearchContentViewController.view)
        return view
    }()

    override func setUI() {
        addChild(recentSearchContentViewController)
        recentSearchContentViewController.didMove(toParent: self)
        
        view.addSubviews([searchBar, contentTableView, noContentLabel, containerView])
    }
    
    override func setLayout() {
        setSearchBarLayout()
        setContentTableViewLayout()
        setNoContentLabelLayout()
        setContainerViewLayout()
    }
    
    override func setDelegate() {}
    
    override func addTarget() {}
    
    func reloadData(with searchText: String) {
        let realm = ContentManager()
        contentList = realm.read(at: searchText)
        contentTableView.reloadData()
        noContentLabel.isHidden = !contentList.isEmpty
    }
    
    func setSearchBarLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    func setContentTableViewLayout() {
        contentTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func setNoContentLabelLayout() {
        noContentLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
        }
    }
    
    func setContainerViewLayout() {
        containerView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        recentSearchContentViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(containerView.snp.edges)
        }
    }
}

extension SearchContentViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            toggleContainerViewVisibility(isShow: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        reloadData(with: searchText)

        toggleContainerViewVisibility(isShow: false)
        
        guard let searchText = searchBar.text else { return }
        recenteSearchManager.add(to: searchText)
    }
    
    func toggleContainerViewVisibility(isShow: Bool) {
        containerView.isHidden = !isShow
        recentSearchContentViewController.reloadData()
    }
}

extension SearchContentViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = contentTableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell", for: indexPath) as? ContentTableViewCell else {
            return UITableViewCell()
        }
        
        let content = contentList[indexPath.row]
        cell.configureCell(title: content.title, memo: content.memo, image: content.imageURL, url: content.sourceURL, isPinned: false, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = contentList[indexPath.row]
        
        let url = item.sourceURL
        let title = item.title
        
        let viewController = WebViewController(sourceURL: url, sourceTitle: title)
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}
