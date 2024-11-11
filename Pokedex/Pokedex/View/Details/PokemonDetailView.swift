//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/21/23.
//

import SwiftUI

struct PokemonDetailView: View {
    @Environment(Manager.self) var manager
    @Binding var areCaptured : String
    
    let pokemon : Pokemon
    
    var body: some View {
        GeometryReader { geometry in
            let minScreenSize = min(geometry.size.width, geometry.size.height)
            let imageSize = min(minScreenSize*0.9, 500)
            
            ScrollView {
                VStack {
                    // Pokemon
                    PokemonCard(areCaptured: $areCaptured, pokemon: pokemon, showID: true, showCaptured: false)
                        .frame(width: imageSize, height: imageSize)
                        .padding(.bottom, 10)
                    CaptureButton(areCaptured: $areCaptured, pokemon: pokemon)
                    // Data
                    BodyMeasurementView(pokemon: pokemon)
                        .padding(.bottom, 10)
                    
                    PokemonTypeView(title: "Types", data: pokemon.types)
                        .padding(.bottom, 10)
                    PokemonTypeView(title: "Weaknesses", data: pokemon.weaknesses)
                    
                    if pokemon.prevEvolution != nil {
                        CategoryRow(areCaptured: $areCaptured, title: "Predecessors", pokemons: manager.getPokemons(by: pokemon.prevEvolution!))
                    }
                    if pokemon.nextEvolution != nil {
                        CategoryRow(areCaptured: $areCaptured, title: "Successors", pokemons: manager.getPokemons(by: pokemon.nextEvolution!))
                    }
                }
            }
            .padding()
            .navigationBarTitle(pokemon.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PokemonDetailView(areCaptured: .constant(String(repeating: "t", count: 151)), pokemon: Pokemon.standard)
        .environment(Manager())
}

struct CaptureButton : View {
    @Environment(Manager.self) var manager
    @Binding var areCaptured : String
    var pokemon : Pokemon
    var index : Int  { pokemon.id-1 }
    var isCaptured : Bool  { Array(areCaptured)[index] == "t" }
    
    var body: some View {
        Button(action: {
            var areCapturedArray = Array(areCaptured)
            if areCapturedArray[index] == "t" {
                areCapturedArray[index] = "f"
                areCaptured = String(areCapturedArray)
            } else {
                areCapturedArray[index] = "t"
                areCaptured = String(areCapturedArray)
            }
        }) {
            Image("Captured")
                .saturation(Array(areCaptured)[index] == "t" ? 1 : 0)
                .opacity(Array(areCaptured)[index] == "t" ? 1 : 0.5)
        }
    }
}

