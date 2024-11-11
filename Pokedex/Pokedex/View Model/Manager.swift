//
//  Manager.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/21/23.
//

import Foundation

typealias Pokemons = [Pokemon]

@Observable
class Manager {
    /* Model */
    let persistence : Persistence<Pokemons>
    var pokemons : Pokemons
    
    /* View */
    var filterType : PokemonType?
    var filteredPokemons : Pokemons  {
        getPokemons(by: filterType)
    }
    
    /* init */
    init() {
        self.persistence = Persistence(filename: "myPokedex")
        self.pokemons = persistence.modelData ?? []
    }
}

extension Manager {
    
    // Persistence
    func save() {
        persistence.save(pokemons)
    }
    
    // Pokemon
    func getIndex(by id: Int) -> Int {
        return pokemons.firstIndex(where: {$0.id == id})!
    }
    
    func getPokemon(by id: Int) -> Pokemon {
        return pokemons.first(where: {$0.id == id})!
    }
    
    func getPokemons(by ids: [Int]) -> Pokemons {
        return pokemons.filter{ ids.contains($0.id) }
    }
    
    func getPokemons(by type : PokemonType?) -> Pokemons {
        return type == nil ? pokemons : pokemons.filter{ $0.types.contains(type!) }
    }
    
//    func toggleIsCapture(for pokemon : Pokemon) {
//        let id = pokemon.id
//        let index = getIndex(by: id)
//        pokemons[index].isCaptured.toggle()
//    }
    
    func isAnyCaptured(areCaptured : String) -> Bool {
        return areCaptured != String(repeating: "f", count:151)
    }
    
    func getCapturedPokemons(areCaptured : String) -> Pokemons {
        var _captured : Pokemons = []
        let areCapturedArray = Array(areCaptured)
        for i in 0..<pokemons.count {
            if areCapturedArray[i] == "t" {
                _captured.append(pokemons[i])
            }
        }
        return _captured
    }
}
