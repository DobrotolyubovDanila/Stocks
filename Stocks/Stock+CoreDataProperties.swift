//
//  Stock+CoreDataProperties.swift
//  Stocks
//
//  Created by Данила on 30.08.2020.
//  Copyright © 2020 Dobrotolyubov Danila. All rights reserved.
//
//

import Foundation
import CoreData


extension Stock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stock> {
        return NSFetchRequest<Stock>(entityName: "Stock")
    }

    @NSManaged public var companyName: String?
    @NSManaged public var image: Data?
    @NSManaged public var ticker: String?
    @NSManaged public var changePrice: Double
    @NSManaged public var price: Double

}
