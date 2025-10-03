//
//  Card.swift
//  Vector: Pusoy Dos
//
//  Created by Karl on 10/2/25.
//

import Foundation

/// Represents a playing card in the game
struct Card: Identifiable, Codable, Equatable, Hashable {
    let id = UUID()
    let suit: Suit
    let rank: Rank
    
    /// The display name of the card (e.g., "A♠", "K♥")
    var displayName: String {
        return "\(rank.displayName)\(suit.symbol)"
    }
    
    /// The image name for the card asset
    var imageName: String {
        return "\(rank.rawValue)_\(suit.rawValue)"
    }
    
    /// Determines if this card can beat another card in a single play
    /// - Parameter other: The card to compare against
    /// - Returns: True if this card beats the other card
    func beats(_ other: Card) -> Bool {
        // In Pusoy Dos, higher rank beats lower rank
        // If ranks are equal, suit doesn't matter for singles
        return rank.beats(other.rank)
    }
}

/// Card suits in Pusoy Dos
enum Suit: String, CaseIterable, Codable {
    case spades = "spades"
    case hearts = "hearts"
    case diamonds = "diamonds"
    case clubs = "clubs"
    
    var symbol: String {
        switch self {
        case .spades: return "♠"
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        }
    }
    
    var color: CardColor {
        switch self {
        case .spades, .clubs: return .black
        case .hearts, .diamonds: return .red
        }
    }
}

/// Card colors for UI styling
enum CardColor {
    case red, black
}

/// Card ranks in Pusoy Dos (2 is lowest, Ace is highest)
enum Rank: String, CaseIterable, Codable {
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    case ace = "A"
    
    var displayName: String {
        return rawValue
    }
    
    /// Numeric value for comparison (2=2, J=11, Q=12, K=13, A=14)
    var numericValue: Int {
        switch self {
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten: return 10
        case .jack: return 11
        case .queen: return 12
        case .king: return 13
        case .ace: return 14
        }
    }
    
    /// Determines if this rank beats another rank
    /// - Parameter other: The rank to compare against
    /// - Returns: True if this rank beats the other rank
    func beats(_ other: Rank) -> Bool {
        return numericValue > other.numericValue
    }
}

/// Hand types in Pusoy Dos
enum HandType: String, CaseIterable, Codable {
    case single = "single"
    case pair = "pair"
    case triple = "triple"
    case straight = "straight"
    case flush = "flush"
    case fullHouse = "full_house"
    case fourOfAKind = "four_of_a_kind"
    case straightFlush = "straight_flush"
    
    var displayName: String {
        switch self {
        case .single: return "Single"
        case .pair: return "Pair"
        case .triple: return "Triple"
        case .straight: return "Straight"
        case .flush: return "Flush"
        case .fullHouse: return "Full House"
        case .fourOfAKind: return "Four of a Kind"
        case .straightFlush: return "Straight Flush"
        }
    }
    
    /// The number of cards required for this hand type
    var cardCount: Int {
        switch self {
        case .single: return 1
        case .pair: return 2
        case .triple: return 3
        case .straight, .flush, .fullHouse, .fourOfAKind, .straightFlush: return 5
        }
    }
}

/// Represents a play made by a player
struct Play: Codable, Equatable {
    let cards: [Card]
    let handType: HandType
    let playerId: UUID
    let timestamp: Date
    
    init(cards: [Card], handType: HandType, playerId: UUID) {
        self.cards = cards
        self.handType = handType
        self.playerId = playerId
        self.timestamp = Date()
    }
}

/// Utility functions for card operations
extension Card {
    /// Creates a standard 52-card deck
    static func createDeck() -> [Card] {
        var deck: [Card] = []
        
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(suit: suit, rank: rank))
            }
        }
        
        return deck
    }
    
    /// Shuffles a deck of cards
    static func shuffle(_ deck: [Card]) -> [Card] {
        return deck.shuffled()
    }
    
    /// Deals cards to players (13 cards each for 4 players)
    static func deal(_ deck: [Card]) -> [[Card]] {
        var hands: [[Card]] = [[], [], [], []]
        var deckIndex = 0
        
        // Deal 13 cards to each player
        for _ in 0..<13 {
            for playerIndex in 0..<4 {
                if deckIndex < deck.count {
                    hands[playerIndex].append(deck[deckIndex])
                    deckIndex += 1
                }
            }
        }
        
        return hands
    }
}
