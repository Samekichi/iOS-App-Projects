//
//  CanvasParameterView.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/15/23.
//

import SwiftUI

struct CanvasParameterView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var canvas : Canvas?
    @State private var name : String = ""
    @State private var width : Double = 400
    @State private var height : Double = 600
    @State private var backgroundColor : CGColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    var body: some View {
        NavigationView {
            Form {
                TextRow(text: $name, title: "name", prompt: "canvas name")
                NumericRow(num: $width, title: "width", defaultNum: 400, range: 10...6000)
                NumericRow(num: $height, title: "height", defaultNum: 600, range: 10...6000)
                ColorPickerRow(title: "background", color: $backgroundColor, defaultColor: CGColor.white)
            }
            .navigationTitle(canvas == nil ? "Add Canvas" : "Edit Canvas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if canvas != nil {
                        Button(action: { saveCanvas() }) {
                            Label("Save", systemImage: "checkmark")
                        }
                    } else {
                        Button(action: { addCanvas() }) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .onAppear {
            if let canvas {
                name = canvas.name
                width = canvas.width
                height = canvas.height
                backgroundColor = canvas.backgroundCanvasColor.cgColor
            }
        }
    }
}

extension CanvasParameterView {
    private func addCanvas() {
        guard let username = UserDefaults.standard.string(forKey: "username") else { return }
        guard let userUUIDString = UserDefaults.standard.string(forKey: "userUUID") else { return }
        
        let creatorIdentifier = CreatorIdentifier(username: username, userUUIDString: userUUIDString)
        let newCanvas = Canvas(name: name,
                               creatorIdentifier: creatorIdentifier,
                               width: width,
                               height: height,
                               backgroundCanvasColor: CanvasColor(backgroundColor))
        modelContext.insert(newCanvas)
        dismiss()
    }
    
    private func saveCanvas() {
        if let canvas {
            modelContext.undoManager?.beginUndoGrouping()
            canvas.name = name
            canvas.width = width
            canvas.height = height
            canvas.backgroundCanvasColor = CanvasColor(backgroundColor)
            canvas.lastModifiedDate = Date()
            modelContext.undoManager?.endUndoGrouping()
        }
        dismiss()
    }
}

#Preview {
    CanvasParameterView()
}

// Row Views
struct TextRow : View {
    @Binding var text : String
    var title : String
    var prompt : String?
    
    var body: some View {
        HStack {
            Text(title.capitalized)
                .frame(width: 60, alignment: .leading)
                .padding(.trailing, 5)
            
            TextField(title,
                      text: $text,
                      prompt: prompt.map { Text($0.capitalized) }
            )
                .foregroundStyle(Color.primary.opacity(0.67))
        }
    }
}

struct NumericRow : View {
    @Binding var num : Double
    var title : String
    var defaultNum : Double
    var range : ClosedRange<Double>
    var tintColor : CGColor?
    var showLabel : Bool = true
    var inputWidth : Double = 67
    
    var body: some View {
        HStack {
            if showLabel {
                Text(title.capitalized)
                    .frame(width: 60, alignment: .leading)
                    .padding(.trailing, 5)
            }
            TextField("",
                      value: $num,
                      formatter: NumberFormatter()
                      )
                .keyboardType(.decimalPad)
                .frame(width: inputWidth)
                .padding(5)
                .background(Color.gray.opacity(0.1))
                .foregroundStyle(Color.primary.opacity(0.67))
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            Slider(value: $num, in: range, step: 1)
                .frame(maxWidth: 200)
                .tint(tintColor.map { Color($0) })
        }
    }
}

struct ColorPickerRow : View {
    var title : String
    @Binding var color : CGColor
    var defaultColor : CGColor = CGColor.white
    
    @State private var red : Double = 255
    @State private var green : Double = 255
    @State private var blue : Double = 255
    
    private var canvasColor : CanvasColor {
        CanvasColor(color)
    }
    
    var body : some View {
        VStack(alignment: .leading) {
            Text(title.capitalized)
            
            HStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(color))
                    .strokeBorder(style: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(.gray)
                    .frame(width: 100, height: 100)
                    .padding(.trailing, 5)
                    .overlay() {
                        ColorPicker("", selection: $color, supportsOpacity: false)
                            .labelsHidden()
                            .frame(width: 100, height: 100)
                    }
                
                VStack(alignment: .leading) {
                    ColorValueView(title: "r", value: $red, range: 0...255, tintColor: CGColor(red: 255, green: 0, blue: 0, alpha: 1))
                    ColorValueView(title: "g", value: $green, range: 0...255, tintColor: CGColor(red: 0, green: 255, blue: 0, alpha: 1))
                    ColorValueView(title: "b", value: $blue, range: 0...255, tintColor: CGColor(red: 0, green: 0, blue: 255, alpha: 1))
                }
            }
        }
        .onAppear {
            red = canvasColor.red * 255
            green = canvasColor.green * 255
            blue = canvasColor.blue * 255
        }
        .onChange(of: color) {
            red = canvasColor.red * 255
            green = canvasColor.green * 255
            blue = canvasColor.blue * 255
        }
        .onChange(of: [red, green, blue]) { _, newRGB in
            color = CGColor(red: newRGB[0]/255, green: newRGB[1]/255, blue: newRGB[2]/255, alpha: 1)
        }
    }
}

struct ColorValueView : View {
    var title : String
    @Binding var value : Double
    var range : ClosedRange<Double>
    var tintColor : CGColor
    
    var body : some View {
        HStack(alignment: .center) {
            Text(title.capitalized)
                .bold()
                .frame(width: 12, height: 12)
                .padding(4)
                .foregroundStyle(.white)
                .background(Color(tintColor))
                .clipShape(RoundedRectangle(cornerRadius: 5))
            NumericRow(num: $value, title: title, defaultNum: value, range: range, tintColor: tintColor, showLabel: false, inputWidth: 33)
        }
    }
}
