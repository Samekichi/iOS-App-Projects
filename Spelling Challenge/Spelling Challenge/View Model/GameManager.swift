//
//  GameManager.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 9/3/23.
//

import Foundation


class GameManager : ObservableObject {
    
    let model : SpellChallenge
    @Published var preferences : Preferences  { didSet { newGame() } }
    var problem : ScrambleProblem
    
    @Published var score : Int
    @Published var wordsFound : [String]
    @Published var pickedLetters : [Character]
    @Published var candidateLetters : [Character]
    @Published var validWords : Set<String>
    @Published var allPangrams : Set<String>
    @Published var isEmpty : Bool
    @Published var isValid : Bool
    
    var title : String  { model.title }
    var language : Language  { preferences.language }
    var numberOfLettersEnum : NumberOfLetters  { preferences.numberOfLetters }
    var numberOfLetters : Int  { numberOfLettersEnum.int }
    var numberOfSides : Int  { numberOfLetters - 1 }
    var mustHave : Character  { candidateLetters[0] }
    
    init() {
        self.model = LionSpell()
        let _preferences = Preferences(language: .english, numberOfLetters: .seven)
        self.preferences = _preferences
        self.problem = ScrambleProblem(_preferences)
        self.score = 0
        self.wordsFound = []
        self.pickedLetters = []
        self.candidateLetters = problem.letters
        self.validWords = problem.validWords
        self.allPangrams = problem.allPangrams
        self.isEmpty = true
        self.isValid = false
    }
    
    // Edit Panel
    func onLetterTapped(letter: Character) {
        pickedLetters.append(letter)
        
        isValid = isPickedLettersValid()
        isEmpty = pickedLetters.isEmpty
    }
    
    func onSubmit() {
        if isValid {
            // Update score
            let _word : String = String(pickedLetters)
            updateScore(wordFound: _word)
            pickedLetters = []
            wordsFound.append(_word)
            isValid = isPickedLettersValid()
            isEmpty = pickedLetters.isEmpty
            // Generate new set of letters
            problem = ScrambleProblem(preferences)
            candidateLetters = problem.letters
            validWords = problem.validWords
            allPangrams = problem.allPangrams
        }
    }
    
    func onDelete() {
        _ = pickedLetters.popLast()
        isValid = isPickedLettersValid()
        isEmpty = pickedLetters.isEmpty
    }
    
    // Function Panel
    func shuffle() {
        // First letter = The must-have
        let _shuffledLetters = candidateLetters[1...].shuffled()
        candidateLetters.replaceSubrange(1..., with: _shuffledLetters)
    }
    
    func newGame() {
        problem = ScrambleProblem(preferences)
        score = 0
        wordsFound = []
        pickedLetters = []
        candidateLetters = problem.letters
        validWords = problem.validWords
        allPangrams = problem.allPangrams
    }
    
    // Hints Sheet
    func getTotalPossiblePoints() -> Int {
        return problem.totalPossiblePoints
    }
    func getNumberOfValidWords() -> Int {
        return problem.numberOfValidWords
    }
    func getNumberOfPangrams() -> Int {
        return problem.numberOfPangrams
    }
    func getWordsDistribution() -> [Int: [Character: [String]]] {
        return problem.wordsDistribution
    }
    
//    func populateFoundWords() {
//        // ...
//        /* Debug Code */
//        let matchedWords : [ String ] = Words.englishWords.filter{ Set($0).isSubset(of: Set(candidateLetters))}
//        print(matchedWords)
//        wordsFound.append(contentsOf: matchedWords.prefix(6))
//    }
    
    
}


extension GameManager {
    
    private func updateScore(wordFound : String) {
        score += ScrambleProblem.scoreOf(wordFound, with: candidateLetters)
    }
    
    private func isPickedLettersValid() -> Bool {
        let word = String(pickedLetters)
        return !wordsFound.contains(word) && validWords.contains(word)
    }

}
