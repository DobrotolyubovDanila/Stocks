//
//  StokeClass.swift
//  Stocks
//
//  Created by Данила on 29.08.2020.
//  Copyright © 2020 Dobrotolyubov Danila. All rights reserved.
//

import UIKit

class StockInformation {
    
    let ticker:String
    let companyName:String
    let exchange:String
    let openTime:Int
    let closeTime:Int
    let openPrice:Double
    let latestPrice:Double
    let change: Double
    var image: UIImage?
    
    //Инициализатор для каста данных
    init? (json: [String:Any]) {
        guard let ticker = json["symbol"] as? String,
        let companyName = json["companyName"] as? String,
        let exchange = json["primaryExchange"] as? String,
        let openTime = json["openTime"] as? Int,
        let closeTime = json["closeTime"] as? Int,
        let openPrice = json["open"] as? Double,
        let latestPrice = json["latestPrice"] as? Double else { return nil }
        
        self.ticker = ticker
        self.companyName = companyName
        self.exchange = exchange
        self.openTime = openTime
        self.closeTime = closeTime
        self.openPrice = openPrice
        self.latestPrice = latestPrice
        self.change = ((latestPrice - openPrice)*1000).rounded()/1000
    }
    
    init? (stock: Stock) {
        guard let ticker = stock.ticker else { return nil }
        guard let name = stock.companyName else { return nil }
        
        guard let imageData = stock.image else { return nil }
        guard let image = UIImage(data: imageData) else { return nil }
        
        self.image = image
        self.companyName = name
        self.ticker = ticker
        self.exchange = ""
        self.openTime = 0
        self.closeTime = 0
        self.latestPrice = stock.price
        self.change = stock.changePrice
        self.openPrice = 0
    }
}
