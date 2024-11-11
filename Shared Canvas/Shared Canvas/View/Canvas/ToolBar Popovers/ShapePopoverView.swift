//
//  ShapePopoverView.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/12/23.
//

import SwiftUI

struct ShapePopoverView: View {
    @Binding var isShapeFilled : Bool
    @Binding var shapeThickness : Double
    @Binding var selectedShape : ShapeType
    @Binding var selectedTool : ToolType
    
    var body : some View {
        VStack{
            Picker("Shape", selection: $selectedShape) {
                ForEach(ShapeType.allCases) { shapeType in
                    Image(systemName: shapeType.iconName).tag(shapeType)
                }
            }
            .pickerStyle(.segmented)
            
            Toggle("Filled", isOn: $isShapeFilled)

            if !isShapeFilled {
                Text(String(format: "Border Width: %.1f", shapeThickness))
                    .foregroundStyle(.gray)
                    .padding(.top, 8)
                HStack {
                    Image(systemName: selectedShape.iconName)
                    Slider(value: $shapeThickness, in: 1...30, step: 0.5)
                    Image(systemName: selectedShape.iconName)
                        .font(.title3)
                        .bold()
                }
            }
        }
        .onChange(of: selectedShape) {
            selectedTool = .shape(selectedShape)
        }
        .padding()
        .presentationCompactAdaptation(.popover)
    }
}

//#Preview {
//    ShapePopoverView()
//}
