//
//  Persistence.swift
//  Campus
//
//  Created by Andrew Wu on 10/1/23.
//

import Foundation

class Persistence<ModelData : Codable> {
    let fileName : String
    let items : ModelData?
    
    init(fileName : String, defaultItems : ModelData? = nil) {
        self.fileName = fileName
        
        let fileUrl = URL.documentsDirectory.appendingPathComponent(fileName + ".json")
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            // Read from .../Documents/
            self.items = decode(from: fileUrl)
        } else {
            // Try return default items
            if let defaultItems = defaultItems {
                self.items = defaultItems
            } else {
            // Read from default asset
                let bundle = Bundle.main
                let initUrl = bundle.url(forResource: "buildings", withExtension: "json")
                guard let initUrl = initUrl else {self.items = nil; return}
                self.items = decode(from: initUrl)
            }
        }
        
        // init helper
        func decode(from url : URL) -> ModelData? {
            var items : ModelData?
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                items = try decoder.decode(ModelData.self, from: data)
            } catch {
                print(error)
                items = nil
            }
            return items
        }
    }
    
    func save(_ items : ModelData) {
        let encoder = JSONEncoder()
        let fileUrl = URL.documentsDirectory.appendingPathComponent(fileName + ".json")
        do {
            let data = try encoder.encode(items)
            try data.write(to: fileUrl)
        } catch {
            print(error)
        }
    }
}






