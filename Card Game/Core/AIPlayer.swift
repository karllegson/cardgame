//
//  AIPlayer.swift
//  Vector: Pusoy Dos
//
//  Created by Karl on 10/2/25.
//

import Foundation

/// AI player that can make intelligent card playing decisions
class AIPlayer {
    private let gameEngine = GameEngine()
    private let difficulty: AIDifficulty
    
    init(difficulty: AIDifficulty = .medium) {
        self.difficulty = difficulty
    }
    
    /// Determines the best play for an AI player
    /// - Parameters:
    ///   - hand: The AI's current hand
    ///   - lastPlay: The last play made (nil if starting new trick)
    ///   - gameVariant: The current game variant
    /// - Returns: The AI's decision (play cards or pass)
    func makeDecision(hand: [Card], lastPlay: Play?, gameVariant: GameVariant) -> AIDecision {
        // If no last play, start with the lowest single card
        guard let lastPlay = lastPlay else {
            return playLowestSingle(hand: hand)
        }
        
        // Find all possible valid plays
        let validPlays = findAllValidPlays(hand: hand, lastPlay: lastPlay, gameVariant: gameVariant)
        
        // If no valid plays, pass
        guard !validPlays.isEmpty else {
            return .pass
        }
        
        // Choose the best play based on difficulty
        switch difficulty {
        case .easy:
            return chooseEasyPlay(validPlays: validPlays, hand: hand)
        case .medium:
            return chooseMediumPlay(validPlays: validPlays, hand: hand, lastPlay: lastPlay)
        case .hard:
            return chooseHardPlay(validPlays: validPlays, hand: hand, lastPlay: lastPlay)
        }
    }
    
    // MARK: - Private Methods
    
    private func playLowestSingle(hand: [Card]) -> AIDecision {
        let sortedHand = hand.sorted { $0.rank.numericValue < $1.rank.numericValue }
        guard let lowestCard = sortedHand.first else { return .pass }
        return .play([lowestCard])
    }
    
    private func findAllValidPlays(hand: [Card], lastPlay: Play, gameVariant: GameVariant) -> [[Card]] {
        var validPlays: [[Card]] = []
        
        // Check all possible combinations
        let combinations = generateAllCombinations(from: hand, ofSize: lastPlay.cards.count)
        
        for combination in combinations {
            let validation = gameEngine.validatePlay(cards: combination, lastPlay: lastPlay, gameVariant: gameVariant)
            if validation.isValid {
                validPlays.append(combination)
            }
        }
        
        return validPlays
    }
    
    private func generateAllCombinations(from cards: [Card], ofSize size: Int) -> [[Card]] {
        guard size <= cards.count else { return [] }
        
        if size == 1 {
            return cards.map { [$0] }
        }
        
        var combinations: [[Card]] = []
        
        for i in 0..<cards.count {
            let remainingCards = Array(cards[(i+1)...])
            let subCombinations = generateAllCombinations(from: remainingCards, ofSize: size - 1)
            
            for subCombination in subCombinations {
                combinations.append([cards[i]] + subCombination)
            }
        }
        
        return combinations
    }
    
    private func chooseEasyPlay(validPlays: [[Card]], hand: [Card]) -> AIDecision {
        // Easy AI: Play the first valid play (often not optimal)
        guard let firstPlay = validPlays.first else { return .pass }
        return .play(firstPlay)
    }
    
    private func chooseMediumPlay(validPlays: [[Card]], hand: [Card], lastPlay: Play) -> AIDecision {
        // Medium AI: Prefer lower cards, avoid high cards when possible
        let sortedPlays = validPlays.sorted { play1, play2 in
            let max1 = play1.map { $0.rank.numericValue }.max() ?? 0
            let max2 = play2.map { $0.rank.numericValue }.max() ?? 0
            return max1 < max2
        }
        
        // Sometimes make suboptimal plays (20% chance)
        if Int.random(in: 1...100) <= 20 && validPlays.count > 1 {
            let randomIndex = Int.random(in: 1..<validPlays.count)
            return .play(validPlays[randomIndex])
        }
        
        return .play(sortedPlays.first ?? validPlays.first!)
    }
    
    private func chooseHardPlay(validPlays: [[Card]], hand: [Card], lastPlay: Play) -> AIDecision {
        // Hard AI: Strategic play based on hand analysis
        let strategicPlay = analyzeStrategicPlay(validPlays: validPlays, hand: hand, lastPlay: lastPlay)
        return .play(strategicPlay)
    }
    
    private func analyzeStrategicPlay(validPlays: [[Card]], hand: [Card], lastPlay: Play) -> [Card] {
        // Count cards by rank to understand hand composition
        let rankCounts = Dictionary(grouping: hand, by: { $0.rank }).mapValues { $0.count }
        
        // Prefer plays that don't break up pairs/triples
        let playsThatPreservePairs = validPlays.filter { play in
            let playRanks = Set(play.map { $0.rank })
            return !playRanks.contains { rank in
                rankCounts[rank] ?? 0 > play.count
            }
        }
        
        if !playsThatPreservePairs.isEmpty {
            // Choose the lowest play that preserves pairs
            return playsThatPreservePairs.min { play1, play2 in
                let max1 = play1.map { $0.rank.numericValue }.max() ?? 0
                let max2 = play2.map { $0.rank.numericValue }.max() ?? 0
                return max1 < max2
            } ?? validPlays.first!
        }
        
        // If no strategic advantage, play the lowest valid play
        return validPlays.min { play1, play2 in
            let max1 = play1.map { $0.rank.numericValue }.max() ?? 0
            let max2 = play2.map { $0.rank.numericValue }.max() ?? 0
            return max1 < max2
        } ?? validPlays.first!
    }
}

/// AI difficulty levels
enum AIDifficulty: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Makes basic plays, sometimes suboptimal"
        case .medium: return "Balanced play with some strategy"
        case .hard: return "Strategic play, preserves hand structure"
        }
    }
}

/// AI decision result
enum AIDecision {
    case play([Card])
    case pass
    
    var isPass: Bool {
        switch self {
        case .play: return false
        case .pass: return true
        }
    }
    
    var cards: [Card]? {
        switch self {
        case .play(let cards): return cards
        case .pass: return nil
        }
    }
}
