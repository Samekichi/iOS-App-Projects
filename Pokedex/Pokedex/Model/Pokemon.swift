//
//  Pokemon.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/21/23.
//

import Foundation

struct Pokemon : Identifiable {
    var id : Int
    var name : String
    var types : [PokemonType]
    var height : Double
    var weight : Double
    var weaknesses : [PokemonType]
    var prevEvolution : [Int]?
    var nextEvolution : [Int]?
    var isCaptured : Bool = false
}


extension Pokemon : Codable {
    enum CodingKeys : String, CodingKey {
        case id, name, types, height, weight, weaknesses, isCaptured, prevEvolution, nextEvolution
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        types = try container.decode([PokemonType].self, forKey: .types)
        height = try container.decode(Double.self, forKey: .height)
        weight = try container.decode(Double.self, forKey: .weight)
        weaknesses = try container.decode([PokemonType].self, forKey: .weaknesses)
        prevEvolution = try container.decodeIfPresent([Int].self, forKey: .prevEvolution)
        nextEvolution = try container.decodeIfPresent([Int].self, forKey: .nextEvolution)
        isCaptured = try container.decodeIfPresent(Bool.self, forKey: .isCaptured) ?? false
    }
}

extension Pokemon {
    static let standard : Pokemon = Pokemon(id:25, name:"Pikachu", types: [.electric], height:0.41, weight:6.0, weaknesses:[.ground], prevEvolution:nil, nextEvolution:[26], isCaptured:true)
    
    var formattedID : String  { String(format: "%03d", id) }
    var formattedHeight : String  { String(format: "%.2f", height) }
    var formattedWeight : String  { String(format: "%.1f", weight) }
}
