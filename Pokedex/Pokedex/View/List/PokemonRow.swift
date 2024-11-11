//
//  PokemonRow.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/21/23.
//

import SwiftUI

struct PokemonRow: View {
    @Binding var areCaptured : String
    var pokemon : Pokemon
    
    var body: some View {
        HStack {
            Text(String(pokemon.id))
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .bold()
                .foregroundStyle(Color.appSecondary)
            Text(pokemon.name)
                .bold()
                .foregroundStyle(Color.appPrimary)
            
            Spacer()
            
            PokemonCard(areCaptured: $areCaptured, pokemon: pokemon)
                .frame(width: 100, height: 100)
        }
        .padding(5)
    }
}

#Preview {
    PokemonRow(areCaptured: .constant(String(repeating: "t", count: 151)), pokemon: Pokemon.standard)
}

