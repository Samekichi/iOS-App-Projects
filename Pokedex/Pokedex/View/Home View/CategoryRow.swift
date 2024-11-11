//
//  CategoryRow.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/28/23.
//

import SwiftUI

struct CategoryRow: View {
    @Binding var areCaptured : String
    let title : String
    var pokemons : Pokemons
    
    var body: some View {
        VStack(alignment: .leading) {
            // Title
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            // Pokemons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    ForEach(pokemons) { pokemon in
                        NavigationLink(destination: PokemonDetailView(areCaptured: $areCaptured, pokemon: pokemon)) {
                            PokemonCard(areCaptured: $areCaptured, pokemon: pokemon)
                                .frame(width: 125, height: 125)
                        }
                    }
                }
            }
        }
        .padding([.top, .bottom])
    }
}

#Preview {
    CategoryRow(areCaptured: .constant(String(repeating: "t", count: 151)), title:"Standards", pokemons: Array(repeating: Pokemon.standard, count: 5))
}
