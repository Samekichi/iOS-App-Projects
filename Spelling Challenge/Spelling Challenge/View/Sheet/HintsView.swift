//
//  HintsView.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 9/10/23.
//

import SwiftUI

struct HintsView: View {
    
    @EnvironmentObject var gameManager : GameManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {

        NavigationView {
            Form {
                
                Section(header: Text("Summary")) {
                    
                    NavigationLink("Total Number of Words: \(gameManager.getNumberOfValidWords())") {   WordsView(words: Array(gameManager.validWords).sorted())
                        
                    }
                    
                    Text("Total Possible Points: \(gameManager.getTotalPossiblePoints())")
                    
                    NavigationLink("Number of Pangrams: \(gameManager.getNumberOfPangrams())") {
                        WordsView(words: Array(gameManager.allPangrams).sorted())
                    }
                    
                }
                
                ForEach(gameManager.getWordsDistribution().keys.sorted(), id: \.self) { wordLength in
                    
                    Section(header: Text("Words of Length \(wordLength)")) {
                        
                        ForEach(gameManager.getWordsDistribution()[wordLength]!.sorted(by: { $0.key < $1.key }), id: \.key) { initial, words in
                            
                            NavigationLink("\(String(initial)): \(words.count)") {
                                WordsView(words: Array(words))
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Hints", displayMode: .inline)
            .navigationBarItems(trailing: Button("Dismiss") { dismiss() })
        }
    }
}


struct WordsView : View {
    let words : [String]
    let columns : [GridItem] = Array(repeating: .init(.flexible()), count:3)

    var body : some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(words, id: \.self) { word in
                    Text(word)
                        .font(.title)
                        .padding()
                    
                }
            }
        }
    }
}
