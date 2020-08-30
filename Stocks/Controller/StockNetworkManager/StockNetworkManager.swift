//
//  StokeNetworkManager.swift
//  Stocks
//
//  Created by Данила on 29.08.2020.
//  Copyright © 2020 Dobrotolyubov Danila. All rights reserved.
//

import Foundation
// Протокол, с помощью которого реализован апдейт интерфейса.
protocol StockNetworkManagerDelegate {
    func displayStockInfo(with stock: StockInformation)
}


class StockNetworkManager {
    // Контроллер, который будет обновлять интерфейс.
    var delegate:StockNetworkManagerDelegate?
    // Функция, выполняющая запрос данных о курсе акций.
    func requestQuote(for symbol: String) {
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?&token=\(apiKey)") else { return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
            (response as? HTTPURLResponse)?.statusCode == 200,
            error == nil {
                self.parseQuote(from: data)
            } else {
                print("Network error!")
            }
        }
        dataTask.resume()
    }
    // Функция, преобразующая  JSON в объект класса StockInformation
    private func parseQuote(from data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard let json = jsonObject as? [String:Any],
                let stockInformation = StockInformation(json: json) else { return print("Invalid JSON") }
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.displayStockInfo(with: stockInformation)
            }
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
        }
    }
}


