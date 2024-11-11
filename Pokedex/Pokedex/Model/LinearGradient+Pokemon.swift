//
//  LinearGradient+Pokemon.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/21/23.
//

import SwiftUI

extension LinearGradient {
    init(pokemon: Pokemon) {
        let colors = pokemon.types.map{ Color(pokemonType: $0) }
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
