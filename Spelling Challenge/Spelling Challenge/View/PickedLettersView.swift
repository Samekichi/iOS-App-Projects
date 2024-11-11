//
//  PickedLettersView.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 8/27/23.
//

import SwiftUI

struct PickedLettersView: View {
    
    @EnvironmentObject var gameManager : GameManager
    let pickedLetters : [ Character ]
    let mustHave : Character
    
    var body: some View {
        if pickedLetters.isEmpty {
            Text("A")
                .font(.title)
                .opacity(0)
        } else {
            HStack {
                ForEach(0..<pickedLetters.count, id:\.self) { index in
                    let char : Character = pickedLetters[index]
                    Text("\(String(char))")
                        .font(.title)
                        .foregroundColor(char == mustHave ? Color(red: 234/255, green: 139/255, blue: 11/255) : .primary)
                }
            }
        }
        
    }
}
