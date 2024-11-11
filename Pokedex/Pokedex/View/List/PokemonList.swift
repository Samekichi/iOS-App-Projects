//
//  PokemonList.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/21/23.
//

import SwiftUI

struct PokemonList: View {
    @Environment(Manager.self) var manager
    @Binding var areCaptured : String
    var filterString : String  {manager.filterType?.rawValue.capitalized ?? "All"}
    
    var body: some View {
        @Bindable var manager = manager
        
        NavigationStack {
            List {
                ForEach(manager.filteredPokemons) { pokemon in
                    NavigationLink(destination: PokemonDetailView(areCaptured: $areCaptured, pokemon: pokemon)) {
                        PokemonRow(areCaptured: $areCaptured, pokemon: pokemon)
                    }
                }
            }
            .navigationTitle(filterString + " Pokemons")
            .toolbar{
                // Filter
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Filter Pokemon List By", selection: $manager.filterType) {
                        Section{ // show all
                            Text("All").tag(PokemonType?.none)
                        }
                        Section{ // filter by type
                            ForEach(PokemonType.allCases) { type in
                                Text(type.rawValue.capitalized).tag(Optional(type))
                            }
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .font(.system(size: 20, weight: .regular, design: .rounded))
        
    }
}

#Preview {
    PokemonList(areCaptured: .constant(String(repeating: "t", count: 151)))
        .environment(Manager())
}
