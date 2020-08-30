//
//  CatalogTableViewController.swift
//  Stocks
//
//  Created by Данила on 30.08.2020.
//  Copyright © 2020 Dobrotolyubov Danila. All rights reserved.
//

import UIKit

class CatalogTableViewController: UITableViewController {
    
    var tickerNameDictionary:[String:String] = [:] {
        didSet {
            arrayKeys = Array(tickerNameDictionary.keys).sorted()
        }
    }
    
    var catalogNetworkManager = CatalogNetworkManager()
    
    var arrayKeys:[String] = []
    
    // Создаем SearchController
    private let searchController = UISearchController(searchResultsController: nil)
    // Отфильтрованный массив имен
    private var filtredNames:[String] = []
    // Свойство, проверяющее на пустоту searchBar
    private var searchBarIsEmpty:Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    // Проверка активности searchController
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    var tickerPassDataDelegate:TickerPassDataDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        
        //производим настройку searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        catalogNetworkManager.delegate = self
        
        let dict = UserSettings.getTickerAndNames()
        if dict.isEmpty {
            // проверка интернет-соединения
            if Reachability.isConnectedToNetwork() {
                catalogNetworkManager.requestQuote()
            } else {
                presentAlert(title: "No Internet Connection", message: "Please connect to the Internet")
            }
        } else {
            tickerNameDictionary = dict
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filtredNames.count
        }
        
        return tickerNameDictionary.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogCell", for: indexPath) as! CatalogCell
        
        cell.delegate = tickerPassDataDelegate
        
        if isFiltering {
            cell.nameLabel.text = filtredNames[indexPath.row]
            cell.tickerLabel.text = tickerNameDictionary[filtredNames[indexPath.row]]
            return cell
        }
        
        cell.nameLabel.text = arrayKeys[indexPath.row]
        cell.tickerLabel.text = tickerNameDictionary[arrayKeys[indexPath.row]]
        
        return cell
    }
    
    private func presentAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension CatalogTableViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String){
        
        filtredNames = arrayKeys.filter({ (name) -> Bool in
            return name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
}

extension CatalogTableViewController:CatalogNetworkManagerDelegate {
    func updateInterface(dict: [String:String]) {
        UserSettings.saveDictionary(dict: dict)
        tickerNameDictionary = dict
        tableView.reloadData()
    }
}



