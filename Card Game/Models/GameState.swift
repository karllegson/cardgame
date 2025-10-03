//
//  GameState.swift
//  Vector: Pusoy Dos
//
//  Created by Karl on 10/2/25.
//

import Foundation

/// Represents the current state of a Pusoy Dos game
struct GameState: Codable, Equatable {
    let id: UUID
    let roomCode: String
    var players: [Player]
    var currentTrick: [Card]
    var turnPlayer: Int
    var passCount: Int
    var gamePhase: GamePhase
    var gameVariant: GameVariant
    var lastPlay: Play?
    var playHistory: [Play]
    var winner: UUID?
    var createdAt: Date
    var startedAt: Date?
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        roomCode: String = String.randomRoomCode(),
        players: [Player] = [],
        currentTrick: [Card] = [],
        turnPlayer: Int = 0,
        passCount: Int = 0,
        gamePhase: GamePhase = .waiting,
        gameVariant: GameVariant = .classic,
        lastPlay: Play? = nil,
        playHistory: [Play] = [],
        winner: UUID? = nil,
        createdAt: Date = Date(),
        startedAt: Date? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.roomCode = roomCode
        self.players = players
        self.currentTrick = currentTrick
        self.turnPlayer = turnPlayer
        self.passCount = passCount
        self.gamePhase = gamePhase
        self.gameVariant = gameVariant
        self.lastPlay = lastPlay
        self.playHistory = playHistory
        self.winner = winner
        self.createdAt = createdAt
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
    
    /// Returns true if the game is ready to start (4 players, all ready)
    var isReadyToStart: Bool {
        return players.count == 4 && players.allSatisfy { $0.isReady }
    }
    
    /// Returns true if the game is currently active
    var isActive: Bool {
        return gamePhase == .active
    }
    
    /// Returns true if the game is completed
    var isCompleted: Bool {
        return gamePhase == .completed
    }
    
    /// Returns the current player
    var currentPlayer: Player? {
        guard turnPlayer < players.count else { return nil }
        return players[turnPlayer]
    }
    
    /// Returns true if a trick should be cleared (3 consecutive passes)
    var shouldClearTrick: Bool {
        return passCount >= 3
    }
    
    /// Returns the number of players who have no cards left
    var playersWithNoCards: Int {
        return players.filter { $0.cardsRemaining == 0 }.count
    }
}

/// Game phases in Pusoy Dos
enum GamePhase: String, Codable, CaseIterable {
    case waiting = "waiting"     // Waiting for players to join and get ready
    case dealing = "dealing"     // Dealing cards to players
    case active = "active"       // Game is in progress
    case completed = "completed" // Game has finished
    case abandoned = "abandoned" // Game was abandoned
    
    var displayName: String {
        switch self {
        case .waiting: return "Waiting for Players"
        case .dealing: return "Dealing Cards"
        case .active: return "Game in Progress"
        case .completed: return "Game Completed"
        case .abandoned: return "Game Abandoned"
        }
    }
}

/// Game variants that can be toggled
enum GameVariant: String, Codable, CaseIterable {
    case classic = "classic"
    case noPass = "no_pass"
    case reverseOrder = "reverse_order"
    case jokerWild = "joker_wild"
    case speedMode = "speed_mode"
    
    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .noPass: return "No Pass"
        case .reverseOrder: return "Reverse Order"
        case .jokerWild: return "Joker Wild"
        case .speedMode: return "Speed Mode"
        }
    }
    
    var description: String {
        switch self {
        case .classic: return "Standard Pusoy Dos rules"
        case .noPass: return "Players must play if they have valid cards"
        case .reverseOrder: return "Play in reverse after each trick"
        case .jokerWild: return "Include 2 jokers as wild cards"
        case .speedMode: return "10-second turn timer"
        }
    }
}

/// Game actions that can be performed
enum GameAction: Codable, Equatable {
    case playerJoined(Player)
    case playerLeft(UUID)
    case playerReady(UUID)
    case playerUnready(UUID)
    case gameStarted
    case cardsDealt([[Card]])
    case cardPlayed(Play)
    case playerPassed(UUID)
    case trickCleared
    case gameCompleted(UUID) // Winner ID
    case gameAbandoned
    case playerDisconnected(UUID)
    case playerReconnected(UUID)
}

/// Game statistics for tracking
struct GameStats: Codable {
    let gameId: UUID
    let duration: TimeInterval
    let totalPlays: Int
    let totalPasses: Int
    let winner: UUID
    let finalScores: [UUID: Int] // Player ID to cards remaining
    let createdAt: Date
    
    init(gameId: UUID, duration: TimeInterval, totalPlays: Int, totalPasses: Int, winner: UUID, finalScores: [UUID: Int]) {
        self.gameId = gameId
        self.duration = duration
        self.totalPlays = totalPlays
        self.totalPasses = totalPasses
        self.winner = winner
        self.finalScores = finalScores
        self.createdAt = Date()
    }
}

/// Utility extensions for GameState
extension GameState {
    /// Creates a new game state with updated values
    func withUpdatedPlayers(_ players: [Player]) -> GameState {
        var newState = self
        newState.players = players
        return newState
    }
    
    /// Creates a new game state with updated turn player
    func withUpdatedTurnPlayer(_ turnPlayer: Int) -> GameState {
        var newState = self
        newState.turnPlayer = turnPlayer
        return newState
    }
    
    /// Creates a new game state with updated pass count
    func withUpdatedPassCount(_ passCount: Int) -> GameState {
        var newState = self
        newState.passCount = passCount
        return newState
    }
    
    /// Creates a new game state with updated game phase
    func withUpdatedGamePhase(_ gamePhase: GamePhase) -> GameState {
        var newState = self
        newState.gamePhase = gamePhase
        return newState
    }
    
    /// Creates a new game state with a new play added
    func withNewPlay(_ play: Play) -> GameState {
        var newState = self
        newState.currentTrick.append(contentsOf: play.cards)
        newState.lastPlay = play
        newState.playHistory.append(play)
        newState.turnPlayer = (turnPlayer + 1) % 4
        newState.passCount = 0
        return newState
    }
    
    /// Creates a new game state with trick cleared
    func withTrickCleared() -> GameState {
        var newState = self
        newState.currentTrick.removeAll()
        newState.passCount = 0
        return newState
    }
}

/// String extension for generating room codes
extension String {
    static func randomRoomCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}
