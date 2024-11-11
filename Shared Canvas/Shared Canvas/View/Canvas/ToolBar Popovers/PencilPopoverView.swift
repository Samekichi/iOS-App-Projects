//
//  PencilPopoverView.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/12/23.
//

import SwiftUI

struct PencilPopoverView: View {
    @Binding var pencilThickness : Double
    
    var body: some View {
        VStack{
            Text(String(format: "Linewidth: %.1f", pencilThickness))
                .foregroundStyle(.gray)
            HStack {
                Image(systemName: "pencil.tip")
                Slider(value: $pencilThickness, in: 1...30, step: 0.5)
                Image(systemName: "pencil.tip")
                    .font(.title)
            }
        }
        .padding()
        .presentationCompactAdaptation(.popover)
    }
}

//#Preview {
//    PencilPopoverView()
//}
