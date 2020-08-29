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
    
    private lazy var companies = [
        "Apple": "AAPL",
        "Microsoft": "MSFT",
        "Google": "GOOG",
        "Amazon": "AMZN",
        "Facebook": "FB"
    ]
    
    var networkManager = StockNetworkManager()
    var stock:StockInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkManager.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        requestQuoteUpdate()
    }
    
    private func requestQuoteUpdate() {
        activityIndicator.startAnimating()
        nameLabel.text = "–"
        tickerLabel.text = "–"
        priceLabel.text = "–"
        priceChangeLabel.text = "–"
        
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(companies.values)[selectedRow]
        networkManager.requestQuote(for: selectedSymbol)
    }
    
    func displayStockInfo(with stock: StockInformation) {
        nameLabel.text = stock.companyName
        priceLabel.text = String(stock.latestPrice)
        tickerLabel.text = stock.ticker
        let change = ((stock.latestPrice - stock.openPrice)*1000).rounded()/1000
        priceChangeLabel.text = String(change)
        
        activityIndicator.stopAnimating()
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

