//
//  ListStockVC.swift
//  Stocks
//
//  Created by Данила on 30.08.2020.
//  Copyright © 2020 Dobrotolyubov Danila. All rights reserved.
//

import UIKit
import CoreData

class ListStockVC: UITableViewController {
    
    var context:NSManagedObjectContext!
    var stockReferenceArray:[Stock] = []
    
    
    var stockInformationArray: [StockInformation] = []
    
    var networkManager = StockNetworkManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkManager.delegate = self
        
        tableView.tableFooterView = UIView()
        
        getDataFromStorage()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stockInformationArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StockCell
        
        cell.nameLabel.text = stockInformationArray[indexPath.row].companyName
        cell.logoImageView.image = stockInformationArray[indexPath.row].image
        cell.tickerLabel.text = stockInformationArray[indexPath.row].ticker
        
        cell.priceLabel.text = String(stockInformationArray[indexPath.row].latestPrice)
        
        cell.changePriceLabel.text = stockInformationArray[indexPath.row].change >= 0 ?   "↗ \(stockInformationArray[indexPath.row].change)" : "↘ \(stockInformationArray[indexPath.row].change)"
        
        cell.changePriceLabel.textColor = stockInformationArray[indexPath.row].change >= 0 ? .green : .red
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard  editingStyle == .delete else { return }
        
        let stock = stockReferenceArray[indexPath.row]
        stockReferenceArray.remove(at: indexPath.row)
        stockInformationArray.remove(at: indexPath.row)
        context.delete(stock)
        
        do {
            try context.save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    
    
    @IBAction func addStock(_ sender: Any) {
        let alert = UIAlertController(title: "Enter the Ticker",
                                      message: "Enter the stock Ticker to see the metrics.",
                                      preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "Ticker"
        }
        alert.addAction(UIAlertAction(title: "Canсel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { (action) in
            guard let symbol = alert.textFields?.first?.text else { return }
            
            if Reachability.isConnectedToNetwork() {
                self.networkManager.requestQuote(for: symbol)
            } else {
                self.presentAlert(title: "No Internet Connection", message: "Please connect to the Internet")
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dvc = segue.destination as? CatalogTableViewController else { return }
        dvc.tickerPassDataDelegate = self
    }
    
    // MARK: -CoreData
    private func getDataFromStorage() {
        let fetchRequest:NSFetchRequest<Stock> = Stock.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "companyName", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            stockReferenceArray = try context.fetch(fetchRequest)
            for item in stockReferenceArray {
                guard let stockInformationItem = StockInformation(stock:item) else { continue }
                self.stockInformationArray.append(stockInformationItem)
            }
            tableView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func saveStock(stockInfo: StockInformation) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Stock", in: context) else { return }
        
        let stockObject = Stock(entity: entity, insertInto: context)
        stockObject.companyName = stockInfo.companyName
        stockObject.ticker = stockInfo.ticker
        stockObject.image = stockInfo.image?.pngData()
        stockObject.changePrice = stockInfo.change
        stockObject.price = stockInfo.latestPrice
        stockReferenceArray.append(stockObject)
        
        do {
            try context!.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    private func presentAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    
    // Функция для обновления данных в памяти.чк
    private func updateData() {
        for item in stockReferenceArray {
            guard let ticker = item.ticker else { continue }
            networkManager.requestQuote(for: ticker)
            
            
            stockReferenceArray.removeFirst()
            stockInformationArray.removeFirst()
            context.delete(item)
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func reloadDataPressed(_ sender: UIBarButtonItem) {
        if Reachability.isConnectedToNetwork() {
            updateData()
        } else {
            self.presentAlert(title: "No Internet Connection", message: "Please connect to the Internet")
        }
    }
    
    
}


extension ListStockVC: StockNetworkManagerDelegate {
    func displayStockInfo(with stockInfo: StockInformation, image: UIImage) {
        stockInfo.image = image
        stockInformationArray.append(stockInfo)
        self.saveStock(stockInfo: stockInfo)
        self.tableView.reloadData()
    }
    
}


extension ListStockVC: TickerPassDataDelegate {
    func addNewTicker(ticker: String?) {
        guard let ticker = ticker else {
            return
        }
        if Reachability.isConnectedToNetwork() {
            self.networkManager.requestQuote(for: ticker)
            
        } else {
            self.presentAlert(title: "No Internet Connection", message: "Please connect to the Internet")
        }
        
    }
}
