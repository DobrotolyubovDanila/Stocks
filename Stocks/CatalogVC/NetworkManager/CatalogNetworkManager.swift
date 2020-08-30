//
//  CatalogNetworkManager.swift
//  Stocks
//
//  Created by Данила on 30.08.2020.
//  Copyright © 2020 Dobrotolyubov Danila. All rights reserved.
//

import Foundation


class CatalogNetworkManager {
    
    var delegate:CatalogNetworkManagerDelegate?
    
    func requestQuote() {
        guard let url = URL(string: "https://cloud.iexapis.com/stable/ref-data/symbols?token=\(apiKey)") else { return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                (response as? HTTPURLResponse)?.statusCode == 200,
                error == nil {
                self.parseQuote(data: data)
            } else {
                print("Network error!")
            }
        }
        dataTask.resume()
    }
    
    private func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard let json = jsonObject as? [[String:Any]] else { return }
            
            var dict:[String:String] = [:]
            for item in json {
                guard let name = item["name"] as? String,
                    let ticker = item["symbol"] as? String else { continue }
                
                dict[name] = ticker
            }
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.updateInterface(dict: dict)
            }
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
        }
    }
    
}

protocol CatalogNetworkManagerDelegate {
    func updateInterface(dict: [String:String])
}
