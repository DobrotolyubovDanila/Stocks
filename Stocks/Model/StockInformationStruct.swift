//
//  StokeClass.swift
//  Stocks
//
//  Created by Данила on 29.08.2020.
//  Copyright © 2020 Dobrotolyubov Danila. All rights reserved.
//

import Foundation

struct StockInformation {
    
    let ticker:String
    let companyName:String
    let exchange:String
    let openTime:Int
    let closeTime:Int
    let openPrice:Double
    let latestPrice:Double
    
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
    }
}
