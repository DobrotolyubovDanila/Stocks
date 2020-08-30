//
//  UserSettings.swift
//  Stocks
//
//  Created by Данила on 30.08.2020.
//  Copyright © 2020 Dobrotolyubov Danila. All rights reserved.
//

import Foundation
//  Класс для хранения данных в каталоге.
// С помощью UserDefaults храним тикер и название компании.
final class UserSettings {
    private init() {}

    static func getTickerAndNames() -> [String:String] {
        let dictFromDefaults = UserDefaults.standard.object([String: String].self, with: "stock")
        guard let dict = dictFromDefaults else { return [:] }
        return dict
    }

    static func saveDictionary(dict: [String:String]) {
        UserDefaults.standard.removeObject(forKey: "stock")
        UserDefaults.standard.set(object: dict, forKey: "stock")
    }
}


extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}
