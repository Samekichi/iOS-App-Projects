//
//  BodyMeasurementView.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/21/23.
//

import SwiftUI

struct BodyMeasurementView : View {
    let pokemon : Pokemon
    
    var body : some View {
        HStack {
                Spacer()
            DimensionView(title: "Height", data: pokemon.formattedHeight, unit: "m")
                Spacer()
            DimensionView(title: "Weight", data: pokemon.formattedWeight, unit: "kg")
                Spacer()
        }
    }
}

#Preview {
    BodyMeasurementView(pokemon: Pokemon.standard)
}


struct DimensionView : View {
    let title : String
    let data : String
    let unit : String
    
    var body : some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appSecondary)
            
            HStack(alignment: .center) {
                Text(data)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appPrimary)
                
                Text(unit)
                    .foregroundStyle(Color.appPrimary)
            }
        }
    }
}
