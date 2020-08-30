//
//  ViewController.swift
//  Stocks
//
//  Created by Данила on 29.08.2020.
//  Copyright © 2020 Dobrotolyubov Danila. All rights reserved.
//

import UIKit

class ViewController: UIViewController, StockNetworkManagerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    
    private var companies: [String:String] = [:] {
        didSet {
            if companies.isEmpty { pickerView.isHidden = true } else { pickerView.isHidden = false
                pickerView.reloadAllComponents()
            }
            
        }
    }
    
    var networkManager = StockNetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkManager.delegate = self
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        activityIndicator.hidesWhenStopped = true
        
        companies = UserSettings.getTickerAndNames()
        if !companies.isEmpty { requestQuoteUpdate() }
    }
    
    private func requestQuoteUpdate() {
        activityIndicator.startAnimating()
        nameLabel.text = "–"
        tickerLabel.text = "–"
        priceLabel.text = "–"
        priceChangeLabel.text = "–"
        priceChangeLabel.textColor = .black
        
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(companies.values)[selectedRow]
        networkManager.requestQuote(for: selectedSymbol)
    }
    
    func displayStockInfo(with stock: StockInformation) {
        nameLabel.text = stock.companyName
        priceLabel.text = String(stock.latestPrice)
        tickerLabel.text = stock.ticker
        
        priceChangeLabel.text = String(stock.change)
        priceChangeLabel.textColor = stock.change >= 0 ? .green : .red
        
        activityIndicator.stopAnimating()
        
        if companies[stock.companyName] == nil {
            companies[stock.companyName] = stock.ticker
            UserSettings.saveDictionary(dict: companies)
        }
    }
    
    @IBAction func searchButtonPressed() {
        
        let alert = UIAlertController(title: "Enter the Ticker",
                                      message: "Enter the stock Ticker to see the metrics.",
                                      preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "Ticker"
        }
        alert.addAction(UIAlertAction(title: "Canсel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { (action) in
            guard let symbol = alert.textFields?.first?.text else { return }
            self.networkManager.requestQuote(for: symbol)
        }))
        present(alert, animated: true, completion: nil)
    }
}





extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.keys.count
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.requestQuoteUpdate()
    }
}



