//
//  CatalogCell.swift
//  Stocks
//
//  Created by Данила on 30.08.2020.
//  Copyright © 2020 Dobrotolyubov Danila. All rights reserved.
//

import UIKit

class CatalogCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tickerLabel: UILabel!
    
    var delegate: TickerPassDataDelegate?
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        delegate?.addNewTicker(ticker: tickerLabel.text)
    }
}
