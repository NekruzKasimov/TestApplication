//
//  NetworkManager.swift
//  currency
//
//  Created by Niko on 8/27/18.
//  Copyright © 2018 Niko. All rights reserved.
//

import Foundation
import SwiftyXMLParser

private struct Constants {
    static let currencies = ["USD", "RUB", "GBP", "EUR"]
}
class NetworkManager {
    
    static var valutes = [Valute]()
    
    class func getCurrencies(completion: @escaping(([Valute]) -> Void)) {
        let dateFormatter : DateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = Date()
        let today = dateFormatter.string(from: date)
        let url = "http://nbt.tj/tj/kurs/export_xml.php?date=\(today)&export=xmlout"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            let xml = XML.parse(data!)
            parseData(xml: xml)
            completion(valutes)
        }
        task.resume()
    }
    
    class func parseData(xml: XML.Accessor) {
        var allValutes = [Valute]()
        let valute = ["ValCurs", "Valute"]
        let array = xml[valute].all
        for index in 0...(array?.count)! - 1 {
            let v = Valute()
            v.charCode = xml[valute][index, "CharCode"].text!
            v.value = xml[valute][index, "Value"].double!
            allValutes.append(v)
        }
        for item in Constants.currencies {
            for valute in allValutes {
                if item == valute.charCode {
                    self.valutes.append(valute)
                }
            }
        }
    }
}
