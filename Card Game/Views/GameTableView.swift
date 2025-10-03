//
//  GameTableView.swift
//  Vector: Pusoy Dos
//
//  Created by Karl on 10/2/25.
//

import SwiftUI
import Combine

/// The main game table view showing all 4 players and the play area
struct GameTableView: View {
    @StateObject private var viewModel = GameTableViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.green.opacity(0.3), .blue.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top players (left and right)
                HStack {
                    // Left player
                    PlayerView(
                        player: viewModel.leftPlayer,
                        position: .left,
                        isCurrentPlayer: viewModel.isCurrentPlayer(.left)
                    )
                    
                    Spacer()
                    
                    // Right player
                    PlayerView(
                        player: viewModel.rightPlayer,
                        position: .right,
                        isCurrentPlayer: viewModel.isCurrentPlayer(.right)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Center play area
                PlayAreaView(
                    currentTrick: viewModel.currentTrick,
                    lastPlay: viewModel.lastPlay
                )
                .frame(height: 200)
                
                Spacer()
                
                // Top player
                PlayerView(
                    player: viewModel.topPlayer,
                    position: .top,
                    isCurrentPlayer: viewModel.isCurrentPlayer(.top)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Current player (bottom) and their hand
                VStack(spacing: 16) {
                    // Current player info
                    PlayerView(
                        player: viewModel.currentPlayer,
                        position: .bottom,
                        isCurrentPlayer: true
                    )
                    
                    // Player's hand
                    if viewModel.gamePhase == .active {
                        CardHandView(
                            cards: viewModel.playerHand,
                            selectedCards: viewModel.selectedCards,
                            onCardTap: { card in
                                viewModel.toggleCardSelection(card)
                            },
                            onPlayCards: {
                                viewModel.playSelectedCards()
                            },
                            onPass: {
                                viewModel.passTurn()
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .topTrailing) {
            // Game controls
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.showGameMenu()
                }) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .background(.black.opacity(0.3))
                        .clipShape(Circle())
                }
                
                if viewModel.gamePhase == .active {
                    // Turn timer
                    if viewModel.turnTimeRemaining > 0 {
                        Text("\(viewModel.turnTimeRemaining)s")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.red.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
        }
        .alert("Game Menu", isPresented: $viewModel.showingGameMenu) {
            Button("Resign") {
                viewModel.resignGame()
            }
            Button("Settings") {
                viewModel.showSettings()
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Game Over", isPresented: $viewModel.showingGameOver) {
            Button("New Game") {
                viewModel.startNewGame()
            }
            Button("Back to Home") {
                dismiss()
            }
        } message: {
            Text(viewModel.gameOverMessage)
        }
        .onAppear {
            viewModel.startGame()
        }
    }
}

/// View representing a player at the table
struct PlayerView: View {
    let player: Player
    let position: PlayerPosition
    let isCurrentPlayer: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Player avatar and info
            VStack(spacing: 4) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(player.isConnected ? .blue.opacity(0.2) : .gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isCurrentPlayer ? .blue : .gray.opacity(0.3), lineWidth: 2)
                        )
                    
                    if player.isConnected {
                        Text(String(player.displayName.prefix(1)).uppercased())
                            .font(.headline)
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.gray)
                    }
                }
                
                // Player name
                Text(player.displayName)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Cards remaining
                if player.cardsRemaining > 0 {
                    Text("\(player.cardsRemaining) cards")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    Text("WINNER!")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            // Ready indicator
            if !player.isReady && player.cardsRemaining == 13 {
                HStack(spacing: 4) {
                    Circle()
                        .fill(.orange)
                        .frame(width: 6, height: 6)
                    Text("Not Ready")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentPlayer ? .blue.opacity(0.1) : .clear)
        )
        .scaleEffect(isCurrentPlayer ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCurrentPlayer)
    }
}

/// Enhanced play area with better visual design
struct PlayAreaView: View {
    let currentTrick: [Card]
    let lastPlay: Play?
    
    var body: some View {
        ZStack {
            // Table background
            RoundedRectangle(cornerRadius: 20)
                .fill(.green.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.green.opacity(0.3), lineWidth: 2)
                )
            
            VStack(spacing: 16) {
                // Current trick
                if !currentTrick.isEmpty {
                    VStack(spacing: 8) {
                        Text("Current Trick")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            ForEach(currentTrick, id: \.id) { card in
                                CardView(card: card, isPlayable: false)
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                }
                
                // Last play
                if let lastPlay = lastPlay {
                    VStack(spacing: 8) {
                        Text("Last Play")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 6) {
                            ForEach(lastPlay.cards, id: \.id) { card in
                                CardView(card: card, isPlayable: false)
                                    .scaleEffect(0.7)
                            }
                        }
                        
                        Text(lastPlay.handType.displayName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Empty state
                if currentTrick.isEmpty && lastPlay == nil {
                    VStack(spacing: 8) {
                        Image(systemName: "suit.spade.fill")
                            .font(.title)
                            .foregroundColor(.green.opacity(0.5))
                        
                        Text("Waiting for first play")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
    }
}

// MARK: - ViewModel

@MainActor
class GameTableViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var playerHand: [Card] = []
    @Published var selectedCards: Set<Card> = []
    @Published var currentTrick: [Card] = []
    @Published var lastPlay: Play?
    @Published var gamePhase: GamePhase = .waiting
    @Published var turnTimeRemaining: Int = 0
    @Published var showingGameMenu = false
    @Published var showingGameOver = false
    @Published var gameOverMessage = ""
    
    private let gameEngine = GameEngine()
    private let soundManager = SoundManager.shared
    private let aiPlayers: [AIPlayer] = [
        AIPlayer(difficulty: .medium),
        AIPlayer(difficulty: .medium),
        AIPlayer(difficulty: .hard)
    ]
    private var gameTimer: Timer?
    
    // Computed properties for players
    var currentPlayer: Player {
        return gameState.players[0] // Human player is always seat 0
    }
    
    var leftPlayer: Player {
        return gameState.players[1]
    }
    
    var topPlayer: Player {
        return gameState.players[2]
    }
    
    var rightPlayer: Player {
        return gameState.players[3]
    }
    
    init() {
        // Initialize with AI players
        let aiNames = ["Alex", "Sam", "Jordan"]
        var players: [Player] = []
        
        // Human player (seat 0)
        players.append(Player(
            displayName: "You",
            seatNumber: 0,
            isReady: true
        ))
        
        // AI players (seats 1-3)
        for i in 1...3 {
            players.append(Player(
                displayName: aiNames[i-1],
                seatNumber: i,
                isReady: true
            ))
        }
        
        self.gameState = GameState(
            players: players,
            gamePhase: .waiting
        )
    }
    
    func startGame() {
        gamePhase = .dealing
        
        // Deal cards
        let hands = gameEngine.dealCards()
        playerHand = hands[0] // Human player gets first hand
        
        // Update player card counts
        for i in 0..<gameState.players.count {
            gameState.players[i].updateCardsRemaining(hands[i].count)
        }
        
        // Find starting player (player with 3 of Diamonds)
        let startingPlayer = gameEngine.findStartingPlayer(hands: hands)
        gameState = gameState.withUpdatedTurnPlayer(startingPlayer)
        gameState = gameState.withUpdatedGamePhase(.active)
        
        gamePhase = .active
        startTurnTimer()
        
        // If AI starts, make their move
        if startingPlayer != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.makeAIMove()
            }
        }
    }
    
    func toggleCardSelection(_ card: Card) {
        if selectedCards.contains(card) {
            selectedCards.remove(card)
        } else {
            selectedCards.insert(card)
        }
        soundManager.playCardFlip()
    }
    
    func playSelectedCards() {
        guard !selectedCards.isEmpty else { return }
        guard gameState.turnPlayer == 0 else { return } // Only human player
        
        let cards = Array(selectedCards)
        let validation = gameEngine.validatePlay(
            cards: cards,
            lastPlay: lastPlay,
            gameVariant: gameState.gameVariant
        )
        
        if validation.isValid {
            let play = Play(
                cards: cards,
                handType: validation.handType!,
                playerId: currentPlayer.id
            )
            
            // Update game state
            gameState = gameState.withNewPlay(play)
            currentTrick = gameState.currentTrick
            lastPlay = play
            
            // Remove cards from hand
            playerHand.removeAll { selectedCards.contains($0) }
            selectedCards.removeAll()
            
            // Update player card count
            gameState.players[0].updateCardsRemaining(playerHand.count)
            
            // Play sound
            soundManager.playCardPlay()
            
            // Check for win
            if playerHand.isEmpty {
                endGame(winner: currentPlayer.id)
                return
            }
            
            // Move to next player
            nextTurn()
        }
    }
    
    func passTurn() {
        guard gameState.turnPlayer == 0 else { return } // Only human player
        
        gameState = gameState.withUpdatedPassCount(gameState.passCount + 1)
        
        // Check if trick should be cleared
        if gameState.shouldClearTrick {
            gameState = gameState.withTrickCleared()
            currentTrick.removeAll()
            soundManager.playTrickClear()
        } else {
            soundManager.playCardPass()
        }
        
        nextTurn()
    }
    
    private func makeAIMove() {
        guard gameState.turnPlayer != 0 else { return } // Not AI's turn
        
        let aiIndex = gameState.turnPlayer - 1
        let aiPlayer = aiPlayers[aiIndex]
        let aiHand = getAIHand(for: gameState.turnPlayer)
        
        let decision = aiPlayer.makeDecision(
            hand: aiHand,
            lastPlay: lastPlay,
            gameVariant: gameState.gameVariant
        )
        
        if decision.isPass {
            // AI passes
            gameState = gameState.withUpdatedPassCount(gameState.passCount + 1)
            
            if gameState.shouldClearTrick {
                gameState = gameState.withTrickCleared()
                currentTrick.removeAll()
            }
        } else {
            // AI plays cards
            let cards = decision.cards!
            let validation = gameEngine.validatePlay(
                cards: cards,
                lastPlay: lastPlay,
                gameVariant: gameState.gameVariant
            )
            
            if validation.isValid {
                let play = Play(
                    cards: cards,
                    handType: validation.handType!,
                    playerId: gameState.players[gameState.turnPlayer].id
                )
                
                gameState = gameState.withNewPlay(play)
                currentTrick = gameState.currentTrick
                lastPlay = play
                
                // Update AI player card count
                let newCardCount = aiHand.count - cards.count
                gameState.players[gameState.turnPlayer].updateCardsRemaining(newCardCount)
                
                // Check for AI win
                if newCardCount == 0 {
                    endGame(winner: gameState.players[gameState.turnPlayer].id)
                    return
                }
            }
        }
        
        nextTurn()
    }
    
    private func getAIHand(for seatNumber: Int) -> [Card] {
        // In a real implementation, we'd track AI hands
        // For now, return a mock hand
        return Card.createDeck().shuffled().prefix(13).map { $0 }
    }
    
    private func nextTurn() {
        gameState = gameState.withUpdatedTurnPlayer((gameState.turnPlayer + 1) % 4)
        startTurnTimer()
        
        // If it's AI's turn, make their move after a delay
        if gameState.turnPlayer != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.makeAIMove()
            }
        }
    }
    
    private func startTurnTimer() {
        gameTimer?.invalidate()
        turnTimeRemaining = 30 // 30 second timer
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.turnTimeRemaining > 0 {
                self.turnTimeRemaining -= 1
            } else {
                // Time's up - auto pass
                if self.gameState.turnPlayer == 0 {
                    self.passTurn()
                }
            }
        }
    }
    
    private func endGame(winner: UUID) {
        gameTimer?.invalidate()
        gameState = gameState.withUpdatedGamePhase(.completed)
        gameState.winner = winner
        
        let winnerName = gameState.players.first { $0.id == winner }?.displayName ?? "Unknown"
        gameOverMessage = "\(winnerName) wins!"
        
        // Play win/lose sound
        if winner == currentPlayer.id {
            soundManager.playGameWin()
        } else {
            soundManager.playGameLose()
        }
        
        showingGameOver = true
    }
    
    func isCurrentPlayer(_ position: PlayerPosition) -> Bool {
        return gameState.turnPlayer == position.seatNumber
    }
    
    func showGameMenu() {
        showingGameMenu = true
    }
    
    func showSettings() {
        // TODO: Show settings
    }
    
    func resignGame() {
        endGame(winner: gameState.players[1].id) // AI wins
    }
    
    func startNewGame() {
        // Reset game state
        gameState = GameState(players: gameState.players)
        playerHand = []
        selectedCards = []
        currentTrick = []
        lastPlay = nil
        gamePhase = .waiting
        turnTimeRemaining = 0
        
        startGame()
    }
}

// MARK: - Preview

#Preview {
    GameTableView()
}
