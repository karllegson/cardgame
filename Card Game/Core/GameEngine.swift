//
//  GameEngine.swift
//  Vector: Pusoy Dos
//
//  Created by Karl on 10/2/25.
//

import Foundation
import Combine

/// Core game engine for Pusoy Dos logic and validation
class GameEngine: ObservableObject {
    @Published var currentGameState: GameState?
    
    // MARK: - Game Validation
    
    /// Validates if a set of cards can be played
    /// - Parameters:
    ///   - cards: The cards to be played
    ///   - lastPlay: The last play made (nil if starting a new trick)
    ///   - gameVariant: The current game variant
    /// - Returns: A validation result with hand type if valid
    func validatePlay(cards: [Card], lastPlay: Play?, gameVariant: GameVariant) -> PlayValidationResult {
        // Check if cards are provided
        guard !cards.isEmpty else {
            return .invalid("No cards selected")
        }
        
        // Check if cards are unique
        guard Set(cards).count == cards.count else {
            return .invalid("Duplicate cards selected")
        }
        
        // Determine hand type
        guard let handType = determineHandType(cards: cards) else {
            return .invalid("Invalid card combination")
        }
        
        // Check if hand type matches expected count
        guard handType.cardCount == cards.count else {
            return .invalid("Incorrect number of cards for \(handType.displayName)")
        }
        
        // If this is the first play of a trick, any valid hand is allowed
        guard let lastPlay = lastPlay else {
            return .valid(handType)
        }
        
        // Check if the play beats the last play
        guard canBeatLastPlay(cards: cards, handType: handType, lastPlay: lastPlay) else {
            return .invalid("This play doesn't beat the last play")
        }
        
        return .valid(handType)
    }
    
    /// Determines the hand type for a set of cards
    /// - Parameter cards: The cards to analyze
    /// - Returns: The hand type, or nil if invalid
    func determineHandType(cards: [Card]) -> HandType? {
        let sortedCards = cards.sorted { $0.rank.numericValue < $1.rank.numericValue }
        
        switch cards.count {
        case 1:
            return .single
            
        case 2:
            return isPair(cards: sortedCards) ? .pair : nil
            
        case 5:
            if isStraightFlush(cards: sortedCards) { return .straightFlush }
            if isFourOfAKind(cards: sortedCards) { return .fourOfAKind }
            if isFullHouse(cards: sortedCards) { return .fullHouse }
            if isFlush(cards: sortedCards) { return .flush }
            if isStraight(cards: sortedCards) { return .straight }
            return nil
            
        default:
            return nil
        }
    }
    
    /// Checks if a play can beat the last play
    /// - Parameters:
    ///   - cards: The cards being played
    ///   - handType: The hand type of the current play
    ///   - lastPlay: The last play made
    /// - Returns: True if the current play beats the last play
    func canBeatLastPlay(cards: [Card], handType: HandType, lastPlay: Play) -> Bool {
        // In Pusoy Dos, you can only play the same hand type
        guard handType == lastPlay.handType else {
            return false
        }
        
        // Compare same hand types
        switch handType {
        case .single:
            return cards[0].beats(lastPlay.cards[0])
            
        case .pair:
            return comparePairs(cards, lastPlay.cards)
            
        case .straight, .flush, .fullHouse, .fourOfAKind, .straightFlush:
            return compareFiveCardHands(cards, handType, lastPlay.cards, lastPlay.handType)
        }
    }
    
    /// Deals cards to players
    /// - Returns: Array of 4 hands, each with 13 cards
    func dealCards() -> [[Card]] {
        let deck = Card.shuffle(Card.createDeck())
        return Card.deal(deck)
    }
    
    /// Determines the starting player (player with 3 of Clubs)
    /// - Parameter hands: The dealt hands
    /// - Returns: The seat number of the player with 3 of Clubs
    func findStartingPlayer(hands: [[Card]]) -> Int {
        let threeOfClubs = Card(suit: .clubs, rank: .three)
        
        for (index, hand) in hands.enumerated() {
            if hand.contains(threeOfClubs) {
                return index
            }
        }
        
        return 0 // Fallback to first player
    }
    
    // MARK: - Private Helper Methods
    
    private func isPair(cards: [Card]) -> Bool {
        return cards.count == 2 && cards[0].rank == cards[1].rank
    }
    
    
    private func isStraight(cards: [Card]) -> Bool {
        guard cards.count == 5 else { return false }
        
        let values = cards.map { $0.rank.numericValue }.sorted()
        
        // Check for regular straight
        for i in 1..<values.count {
            if values[i] != values[i-1] + 1 {
                return false
            }
        }
        
        return true
    }
    
    private func isFlush(cards: [Card]) -> Bool {
        guard cards.count == 5 else { return false }
        
        let firstSuit = cards[0].suit
        return cards.allSatisfy { $0.suit == firstSuit }
    }
    
    private func isFullHouse(cards: [Card]) -> Bool {
        guard cards.count == 5 else { return false }
        
        let rankCounts = Dictionary(grouping: cards, by: { $0.rank }).mapValues { $0.count }
        let counts = rankCounts.values.sorted()
        
        return counts == [2, 3]
    }
    
    private func isFourOfAKind(cards: [Card]) -> Bool {
        guard cards.count == 5 else { return false }
        
        let rankCounts = Dictionary(grouping: cards, by: { $0.rank }).mapValues { $0.count }
        return rankCounts.values.contains(4)
    }
    
    private func isStraightFlush(cards: [Card]) -> Bool {
        return isStraight(cards: cards) && isFlush(cards: cards)
    }
    
    private func isFiveCardHand(_ handType: HandType) -> Bool {
        return handType.cardCount == 5
    }
    
    private func comparePairs(_ cards1: [Card], _ cards2: [Card]) -> Bool {
        // Both pairs should have the same rank, so compare by highest suit
        let maxSuit1 = max(cards1[0].suit.suitValue, cards1[1].suit.suitValue)
        let maxSuit2 = max(cards2[0].suit.suitValue, cards2[1].suit.suitValue)
        return maxSuit1 > maxSuit2
    }
    
    
    private func compareFiveCardHands(_ cards1: [Card], _ handType1: HandType, _ cards2: [Card], _ handType2: HandType) -> Bool {
        // First compare hand types
        if handType1 != handType2 {
            return handType1.rawValue > handType2.rawValue
        }
        
        // Same hand type, compare by highest card
        let max1 = cards1.map { $0.rank.numericValue }.max() ?? 0
        let max2 = cards2.map { $0.rank.numericValue }.max() ?? 0
        
        return max1 > max2
    }
}

/// Result of play validation
enum PlayValidationResult {
    case valid(HandType)
    case invalid(String)
    
    var isValid: Bool {
        switch self {
        case .valid: return true
        case .invalid: return false
        }
    }
    
    var handType: HandType? {
        switch self {
        case .valid(let handType): return handType
        case .invalid: return nil
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .valid: return nil
        case .invalid(let message): return message
        }
    }
}
