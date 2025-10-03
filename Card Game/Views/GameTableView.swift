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
        GeometryReader { geometry in
            ZStack {
                // Beautiful background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.3, blue: 0.1),
                        Color(red: 0.2, green: 0.4, blue: 0.2),
                        Color(red: 0.1, green: 0.2, blue: 0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Main game layout - optimized for landscape
                HStack(spacing: 8) {
                    // Left player
                    VStack {
                        Spacer()
                        PlayerView(
                            player: viewModel.leftPlayer,
                            position: .left,
                            isCurrentPlayer: viewModel.isCurrentPlayer(.left)
                        )
                        Spacer()
                    }
                    .frame(width: 80)
                    
                    // Center game area
                    VStack(spacing: 4) {
                        // Top bar with game info
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Text("Vector: Pusoy Dos")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { viewModel.showGameMenu() }) {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        
                        // Top player
                        PlayerView(
                            player: viewModel.topPlayer,
                            position: .top,
                            isCurrentPlayer: viewModel.isCurrentPlayer(.top)
                        )
                        .padding(.vertical, 4)
                        
                        // Play area
                        PlayAreaView(
                            currentTrick: viewModel.currentTrick,
                            lastPlay: viewModel.lastPlay
                        )
                        .frame(height: 120)
                        
                        // Current player (bottom)
                        PlayerView(
                            player: viewModel.currentPlayer,
                            position: .bottom,
                            isCurrentPlayer: true
                        )
                        .padding(.vertical, 4)
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Button(action: { viewModel.passTurn() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "hand.raised.fill")
                                        .font(.caption)
                                    Text("Pass")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.orange)
                                .cornerRadius(20)
                            }
                            .disabled(viewModel.selectedCards.isEmpty)
                            
                            Button(action: { viewModel.playSelectedCards() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "play.fill")
                                        .font(.caption)
                                    Text("Play")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(viewModel.selectedCards.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(20)
                            }
                            .disabled(viewModel.selectedCards.isEmpty)
                        }
                        .padding(.vertical, 4)
                        
                        // Player's cards - horizontal scroll
                        if viewModel.gamePhase == .active {
                            CardHandView(
                                cards: viewModel.playerHand,
                                selectedCards: viewModel.selectedCards,
                                onCardTap: { card in
                                    viewModel.toggleCardSelection(card)
                                }
                            )
                            .frame(height: 80)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Right player
                    VStack {
                        Spacer()
                        PlayerView(
                            player: viewModel.rightPlayer,
                            position: .right,
                            isCurrentPlayer: viewModel.isCurrentPlayer(.right)
                        )
                        Spacer()
                    }
                    .frame(width: 80)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
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

/// Compact player view for landscape
struct PlayerView: View {
    let player: Player
    let position: PlayerPosition
    let isCurrentPlayer: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            // Player avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                isCurrentPlayer ? .blue : .gray.opacity(0.3),
                                isCurrentPlayer ? .blue.opacity(0.7) : .gray.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(isCurrentPlayer ? .white : .gray.opacity(0.5), lineWidth: 2)
                    )
                
                if player.isConnected {
                    Text(String(player.displayName.prefix(1)).uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "wifi.slash")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Player name and AI difficulty
            VStack(spacing: 1) {
                Text(player.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Show AI difficulty for AI players
                if player.seatNumber > 0 {
                    Text("AI")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .lineLimit(1)
                }
            }
            
            // Cards remaining
            if player.cardsRemaining > 0 {
                Text("\(player.cardsRemaining)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .cornerRadius(8)
            } else {
                Text("WIN!")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
        .scaleEffect(isCurrentPlayer ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCurrentPlayer)
    }
}

/// Compact play area for landscape
struct PlayAreaView: View {
    let currentTrick: [Card]
    let lastPlay: Play?
    
    var body: some View {
        ZStack {
            // Table background
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.4, blue: 0.2),
                            Color(red: 0.1, green: 0.3, blue: 0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            
            VStack(spacing: 8) {
                // Current trick
                if !currentTrick.isEmpty {
                    VStack(spacing: 4) {
                        Text("Current Trick")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack(spacing: 4) {
                            ForEach(currentTrick, id: \.id) { card in
                                CardView(card: card, isPlayable: false)
                                    .scaleEffect(0.6)
                            }
                        }
                    }
                }
                
                // Last play
                if let lastPlay = lastPlay {
                    VStack(spacing: 4) {
                        Text("Last Play")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack(spacing: 3) {
                            ForEach(lastPlay.cards, id: \.id) { card in
                                CardView(card: card, isPlayable: false)
                                    .scaleEffect(0.5)
                            }
                        }
                        
                        Text(lastPlay.handType.displayName)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Empty state
                if currentTrick.isEmpty && lastPlay == nil {
                    VStack(spacing: 4) {
                        Image(systemName: "suit.spade.fill")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Waiting for first play")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .padding(8)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
        
        // AI makes decision instantly (no delay needed)
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
        // For now, return a mock hand based on remaining cards
        let remainingCards = gameState.players[seatNumber].cardsRemaining
        return Card.createDeck().shuffled().prefix(remainingCards).map { $0 }
    }
    
    private func nextTurn() {
        gameState = gameState.withUpdatedTurnPlayer((gameState.turnPlayer + 1) % 4)
        startTurnTimer()
        
        // If it's AI's turn, make their move after a delay
        if gameState.turnPlayer != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.makeAIMove()
            }
        }
    }
    
    private func startTurnTimer() {
        gameTimer?.invalidate()
        turnTimeRemaining = 30 // 30 second timer
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
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
    
    private func getAIDifficulty(for seatNumber: Int) -> String {
        let aiIndex = seatNumber - 1
        if aiIndex >= 0 && aiIndex < aiPlayers.count {
            switch aiPlayers[aiIndex].difficulty {
            case .easy: return "EASY"
            case .medium: return "MED"
            case .hard: return "HARD"
            }
        }
        return "AI"
    }
}

// MARK: - Preview

#Preview {
    GameTableView()
}