//
//  NewChatVC.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-09.
//

import UIKit
import JGProgressHUD

class NewChatVC: UIViewController, UISearchBarDelegate {
    
    let activityIndicator = JGProgressHUD()
    
    let search: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    let noUsersFound: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Users Found"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = search
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didCancel))
        search.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }
    
    @objc func didCancel() {
        dismiss(animated: true, completion: nil)
    }
}
