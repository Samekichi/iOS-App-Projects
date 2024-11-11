//
//  PokemonCard.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/21/23.
//

import SwiftUI

struct PokemonCard: View {
    @Binding var areCaptured : String
    let pokemon : Pokemon
    let showID : Bool
    let showCaptured : Bool
    var isCaptured : Bool  { Array(areCaptured)[pokemon.id-1] == "t" }
    
    init(areCaptured: Binding<String>, pokemon:Pokemon, showID:Bool = false, showCaptured:Bool = true) {
        self._areCaptured = areCaptured
        self.pokemon = pokemon
        self.showID = showID
        self.showCaptured = showCaptured
    }
    
    var body: some View {
        GeometryReader { geometry in
            let minScreenSize = min(geometry.size.width, geometry.size.height)
            let imageSize = max(minScreenSize*0.15, 30)
            let padding = max(minScreenSize*0.05, 10)
            
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .bottomTrailing) {
                    Image(pokemon.formattedID)
                        .resizable()
                        .scaledToFit()
                        .padding(padding*2)
                        .background(LinearGradient(pokemon: pokemon), in: RoundedRectangle(cornerRadius: 20))
                    
                    if showID {
                        Text(pokemon.formattedID)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.black)
                            .padding(padding)
                    }
                }
                if showCaptured && isCaptured {
                    Image("Captured")
                        .resizable()
                        .frame(width: imageSize, height: imageSize)
                        .padding(padding/1.5)
                }
            }
        }
    }
}

#Preview {
    PokemonCard(areCaptured: .constant(String(repeating: "t", count: 151)), pokemon: Pokemon.standard, showID: true)
}
