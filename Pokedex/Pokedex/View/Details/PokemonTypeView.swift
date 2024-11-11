//
//  PokemonTypeView.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/21/23.
//

import SwiftUI

struct PokemonTypeView: View {
    let title : String
    let data : [PokemonType]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(data) {type in
                        Text(type.rawValue.capitalized)
                            .padding([.leading, .trailing], 10)
                            .padding([.top, .bottom], 8)
                            .background(Color(pokemonType: type), in: Capsule())
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    PokemonTypeView(title: "Weaknesses", data: Pokemon.standard.weaknesses)
}
