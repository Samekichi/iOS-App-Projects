//
//  Persistence.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import Foundation

class Persistence<ModelData:Decodable> {
    
    let fileName : String
    let items : ModelData?
    
    init(fileName:String) {
        self.fileName = fileName
        let fileurl = URL.documentsDirectory.appendingPathComponent(fileName + ".json")
        if FileManager.default.fileExists(atPath: fileurl.path) {
            self.items = decode(from: fileurl)
        } else {
            let bundle = Bundle.main
            let initurl = bundle.url(forResource: fileName, withExtension: "json")
            guard let initurl = initurl  else {self.items = nil; return}
            items = decode(from: initurl)
        }
        
        // decode helper
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
    
}
