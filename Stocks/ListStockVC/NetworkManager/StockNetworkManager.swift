//
//  StokeNetworkManager.swift
//  Stocks
//
//  Created by Данила on 29.08.2020.
//  Copyright © 2020 Dobrotolyubov Danila. All rights reserved.
//

import UIKit
// Протокол, с помощью которого реализован апдейт интерфейса.
protocol StockNetworkManagerDelegate {
    func displayStockInfo(with stock: StockInformation, image: UIImage)
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
                
                guard let urlForImage = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/logo?&token=\(apiKey)") else { return }
                
                let dT = URLSession.shared.dataTask(with: urlForImage) { (dataImage, response, error) in
                    if let dataImage = dataImage,
                        (response as? HTTPURLResponse)?.statusCode == 200,
                        error == nil {
                        
                        self.parseQuote(dataStock: data, dataImage: dataImage)
                        
                    } else {
                        print("Network error!")
                    }
                }
                dT.resume()
                
            } else {
                print("Network error!")
            }
        }
        dataTask.resume()
        
        
    }
    
    // Функция, преобразующая  JSON в объект класса StockInformation и инициирующая апдейт интерфейса
    private func parseQuote(dataStock: Data, dataImage:Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: dataStock)
            guard let json = jsonObject as? [String:Any],
                let stockInformation = StockInformation(json: json) else { return print("Invalid JSON") }
            
            let imageUrlDict = try JSONSerialization.jsonObject(with: dataImage) as? [String: String]
            guard let image = fetchImage(urlString: imageUrlDict?["url"]) else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.displayStockInfo(with: stockInformation, image: image)
                
            }
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
        }
    }
    
    // MARK: - Work with Image
    
    private func fetchImage(urlString: String?) -> UIImage? {
        guard let urlString = urlString else { return nil }
        guard let url = URL(string: urlString) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        return image
    }
}


