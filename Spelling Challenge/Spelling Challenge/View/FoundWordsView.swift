//
//  FoundWordsView.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 8/26/23.
//

import SwiftUI

struct FoundWordsView: View {
    
    let foundWords : [ String ]
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView(.horizontal, showsIndicators: false) {
                
                if foundWords.isEmpty {
                    Text("Invisible Text")
                        .id(-1)
                        .opacity(0)
                        .padding()
                } else {
                    HStack {
                        ForEach(0..<foundWords.count, id: \.self) { i in
                            let word : String = foundWords[i]
                            FoundWordView(word: word)
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                }
            }
            .font(.title)
            .background(Color("PrimaryColor"))
            .onChange(of: foundWords.count-1) { _ in
                withAnimation {
                    reader.scrollTo(foundWords.count-1, anchor: .leading)
            }}
        }
    }
}


struct FoundWordView : View {
    
    let word : String
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<word.count, id: \.self) { i in
                let char = word[word.index(word.startIndex, offsetBy:   i)]
                Text("\(String(char))")
                    .foregroundColor(.white)
            }
            Text(" ")
        }
    }
}
