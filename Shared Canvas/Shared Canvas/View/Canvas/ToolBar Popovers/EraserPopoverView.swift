//
//  EraserPopoverView.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/13/23.
//

import SwiftUI

struct EraserPopoverView: View {
    @Binding var eraserThickness : Double
    
    var body: some View {
        VStack{
            Text(String(format: "Eraser Width: %.1f", eraserThickness))
                .foregroundStyle(.gray)
            HStack {
                Image(systemName: "eraser")
                Slider(value: $eraserThickness, in: 1...30, step: 0.5)
                Image(systemName: "eraser")
                    .font(.title)
            }
        }
        .padding()
        .presentationCompactAdaptation(.popover)
    }
}

//#Preview {
//    EraserPopoverView()
//}
