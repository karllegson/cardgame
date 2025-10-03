//
//  Player.swift
//  Vector: Pusoy Dos
//
//  Created by Karl on 10/2/25.
//

import Foundation

/// Represents a player in the game
struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    let displayName: String
    let avatarUrl: String?
    let seatNumber: Int
    var isReady: Bool
    var isConnected: Bool
    var cardsRemaining: Int
    var isCurrentPlayer: Bool
    
    init(
        id: UUID = UUID(),
        displayName: String,
        avatarUrl: String? = nil,
        seatNumber: Int,
        isReady: Bool = false,
        isConnected: Bool = true,
        cardsRemaining: Int = 13,
        isCurrentPlayer: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.seatNumber = seatNumber
        self.isReady = isReady
        self.isConnected = isConnected
        self.cardsRemaining = cardsRemaining
        self.isCurrentPlayer = isCurrentPlayer
    }
    
    /// Updates the player's ready status
    mutating func setReady(_ ready: Bool) {
        isReady = ready
    }
    
    /// Updates the player's connection status
    mutating func setConnected(_ connected: Bool) {
        isConnected = connected
    }
    
    /// Updates the number of cards remaining
    mutating func updateCardsRemaining(_ count: Int) {
        cardsRemaining = count
    }
    
    /// Sets whether this player is the current player
    mutating func setCurrentPlayer(_ isCurrent: Bool) {
        isCurrentPlayer = isCurrent
    }
}

/// Player statistics for tracking performance
struct PlayerStats: Codable {
    let playerId: UUID
    let gamesPlayed: Int
    let gamesWon: Int
    let averageCardsRemaining: Double
    let winRate: Double
    let lastPlayed: Date
    
    init(playerId: UUID) {
        self.playerId = playerId
        self.gamesPlayed = 0
        self.gamesWon = 0
        self.averageCardsRemaining = 0.0
        self.winRate = 0.0
        self.lastPlayed = Date()
    }
    
    /// Calculates win rate as a percentage
    var winRatePercentage: Double {
        guard gamesPlayed > 0 else { return 0.0 }
        return (Double(gamesWon) / Double(gamesPlayed)) * 100.0
    }
}


/// Player actions that can be performed
enum PlayerAction: String, Codable {
    case join = "join"
    case leave = "leave"
    case ready = "ready"
    case unready = "unready"
    case play = "play"
    case pass = "pass"
    case disconnect = "disconnect"
    case reconnect = "reconnect"
}

/// Represents a player action with associated data
struct PlayerActionData: Codable {
    let action: PlayerAction
    let playerId: UUID
    let timestamp: Date
    let data: [String: String]? // Additional action-specific data
    
    init(action: PlayerAction, playerId: UUID, data: [String: String]? = nil) {
        self.action = action
        self.playerId = playerId
        self.timestamp = Date()
        self.data = data
    }
}

/// Player positions around the table
enum PlayerPosition: Int, CaseIterable {
    case bottom = 0
    case left = 1
    case top = 2
    case right = 3
    
    var seatNumber: Int {
        return self.rawValue
    }
    
    var displayName: String {
        switch self {
        case .bottom: return "Bottom"
        case .left: return "Left"
        case .top: return "Top"
        case .right: return "Right"
        }
    }
}
