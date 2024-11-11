//
//  HomeView.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/28/23.
//

import SwiftUI

struct HomeView: View {
    @Environment(Manager.self) var manager
    @AppStorage(UserDefaultsKeys.areCaptured) var areCaptured : String = String(repeating: "f", count: 151)
    
    var body: some View {
        NavigationStack {
            List {
                // => "All Pokemons"
                NavigationLink(destination: PokemonList(areCaptured: $areCaptured)) {
                    Text("All Pokemons")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                }
                
                // Captured
                if manager.isAnyCaptured(areCaptured: areCaptured) {
                    CategoryRow(areCaptured: $areCaptured, title: "Captured", pokemons: manager.getCapturedPokemons(areCaptured: areCaptured))
                }
                
                // All Types
                ForEach(PokemonType.allCases) { type in
                    CategoryRow(areCaptured: $areCaptured, title: type.rawValue.capitalized, pokemons: manager.getPokemons(by: type))
                }
            }
            .listStyle(.inset)
            .navigationTitle("Pokédex")
        }
    }
}

#Preview {
    HomeView()
        .environment(Manager())
}
