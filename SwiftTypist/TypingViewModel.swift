import SwiftUI

@Observable
class TypingViewModel {
    var workingText = ""
    // Need two seperate indices for working text and rolling text, because
    // if the user gets to the end of a word without typing a space or a
    // newline, the preceding text should include all of those incorrect
    // characters without affecting the succeeding text. Hope that makes
    // sense, future me.
    var indexIntoRollingText = 0
    var currentWorkingTextIndex = 0
    var asciiString: AsciiString
    var wordStack = [Int]()
    var errorPositions = Set<Int>()
    var didAdvanceRollingText = Set<Int>()
    
    var mode: TypingMode = .realWorld(.punctuation)
    
    private var sessionStartedAt = Date()
    private var lastKeyStrokedAt = Date()
    
    init(asciiString: AsciiString) {
        self.asciiString = asciiString
    }
    
    var currentWPM: Double {
        let timeElapsed = Date().timeIntervalSince(sessionStartedAt) / 60.0
        let wordsTyped = Double(workingText.count) / 5.0
        return timeElapsed > 0 ? wordsTyped / timeElapsed : 0
    }
    
    var currentAccuracy: Double {
        guard !errorPositions.isEmpty else { return 100 }
        
        let totalCharacters = workingText.count
        return Double(totalCharacters - errorPositions.count) / Double(totalCharacters) * 100
    }
    
    func handleDeletion() {
        guard currentWorkingTextIndex > 0 else { return }
        
        let indexToRemove = currentWorkingTextIndex - 1
        workingText.removeLast()
        currentWorkingTextIndex -= 1
        
        if didAdvanceRollingText.contains(indexToRemove) {
            indexIntoRollingText -= 1
            didAdvanceRollingText.remove(indexToRemove)
        }
        
        errorPositions.remove(indexToRemove)
    }
    
    func handleCharacterInput(_ characters: String) {
        guard let firstChar = characters.first else { return }
        
        let neededCharacter = asciiString[indexIntoRollingText]
        workingText.append(contentsOf: characters)
        
        if firstChar != neededCharacter {
            errorPositions.insert(currentWorkingTextIndex)
            currentWorkingTextIndex += characters.count
            
            if neededCharacter != " " {
                indexIntoRollingText += 1
                didAdvanceRollingText.insert(currentWorkingTextIndex - 1)
            }
        } else {
            errorPositions.remove(currentWorkingTextIndex)
            didAdvanceRollingText.insert(currentWorkingTextIndex)
            
            currentWorkingTextIndex += characters.count
            indexIntoRollingText += characters.count
            
            if firstChar == " " {
                wordStack.append(currentWorkingTextIndex)
            }
        }
    }
}
