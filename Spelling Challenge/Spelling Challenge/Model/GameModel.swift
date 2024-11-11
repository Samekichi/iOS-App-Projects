//
//  GameModel.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 9/3/23.
//

import Foundation


// Game
struct LionSpell : SpellChallenge {
//    let preferences : Preferences = Preferences(language: .english, numberOfLetters: .five)
    let title : String = "LION SPELL"
}

protocol SpellChallenge {
//    var preferences : Preferences {get}
    var title : String {get}
    // other parameters ...
}


// Preference
struct Preferences {
    var language : Language
    var numberOfLetters : NumberOfLetters
}

enum Language : String, CaseIterable, Identifiable {
    case english, french, italian, german
    var id : Self { self }
}

enum NumberOfLetters : String, CaseIterable, Identifiable {
    case five = "5"
    case six = "6"
    case seven = "7"
    var id : Self { self }
    
    var int : Int {
        switch self {
        case .five:
            return 5
        case .six:
            return 6
        case .seven:
            return 7
        }
    }
}


// Problem
struct ScrambleProblem {
    
    // Preferences
    let language : Language
    let numberOfLetters : Int
    
    // Problem Data
    let validWords : Set<String>
    let letters : [Character]
    
    // Stats for View
    var numberOfValidWords : Int  { validWords.count }
    var totalPossiblePoints : Int  {
        var _totalPoints : Int = 0
        validWords.forEach { word in
            _totalPoints += ScrambleProblem.scoreOf(word, with: letters)
        }
        return _totalPoints
    }
    var allPangrams : Set<String>  { validWords.filter {Set($0) == Set(letters)} }
    var numberOfPangrams : Int  { allPangrams.count }
    var wordsDistribution : [ Int : [ Character : [String] ] ]  {  // [ wordLength: [ initialCharacter: wordCount ] ]
        
        return validWords.reduce(into: [:]) { distribution, word in
            let length = word.count
            let initial = word.first!
            
            distribution[length, default: [:]][initial, default: []] .append(word)
        }
    }
    
}


extension ScrambleProblem {
    
    init(_ preferences : Preferences) {
        // Load preferences
        self.language = preferences.language
        self.numberOfLetters = preferences.numberOfLetters.int
        precondition(1 <= numberOfLetters && numberOfLetters <= 26)
        // Load words
        let words : [String] = ScrambleProblem.allWords[language] ?? []
        
        // Generate problem
        (self.validWords, self.letters) = ScrambleProblem.generateProblem(from: words, in: language, numberOfLetters: numberOfLetters)
        
    }
    
    
    static let allWords : [ Language: [String] ] = [
        .english: Words.englishWords,
        .french: Words.frenchWords,
        .italian: Words.italianWords,
        .german: Words.germanWords
    ]
    
    static func generateProblem(from words : [String], in language : Language, numberOfLetters : Int) -> (Set<String>, [Character]) {
        
        var validWords : Set<String> = []
        var letterSet : Set<Character> = []
        var letters : [Character]
        let mustHave : Character
        
        // Ensure a valid n-letter word
        let nLetterWords : [String] = words.filter{ Set($0).count == numberOfLetters }
        precondition(!nLetterWords.isEmpty)
        let candidateWord = nLetterWords.randomElement()
        letterSet = Set(candidateWord!)
        letters = Array(letterSet)
        mustHave = letters[0]
        precondition(letters.count == numberOfLetters)
        
        // Populate valid words
        validWords = Set(words.filter{ Set($0).isSubset(of: letterSet) && $0.contains(mustHave)})
        
        return (validWords, letters)
    }
    
    static func scoreOf(_ word : String, with letters : [Character]) -> Int {
        var score : Int = 0
        let length : Int = word.count
        // Score of length
        if length == 4 {
            score += 1
        } else if length >= 5 {
            score += length
        }
        // Score of Pangram
        if Set(word) == Set(letters) {
            score += 10
        }
        return score
    }
    
}
