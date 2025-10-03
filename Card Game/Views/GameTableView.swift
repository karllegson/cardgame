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
                // Wooden table background (like the reference Pusoy Dos app)
                ZStack {
                    // Base wooden color
                    Color(red: 0.4, green: 0.2, blue: 0.1)
                    
                    // Wood grain texture effect
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.5, green: 0.3, blue: 0.15),
                            Color(red: 0.3, green: 0.15, blue: 0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Subtle wood plank lines
                    VStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.black.opacity(0.1))
                                .frame(height: 1)
                            Spacer()
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Main game layout - optimized for landscape
                HStack(spacing: 4) {
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
                    .frame(width: 60)
                    
                    // Center game area
                    VStack(spacing: 2) {
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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        
                        // Top player
                        PlayerView(
                            player: viewModel.topPlayer,
                            position: .top,
                            isCurrentPlayer: viewModel.isCurrentPlayer(.top)
                        )
                        .padding(.vertical, 2)
                        
                        // Play area
                        PlayAreaView(
                            currentTrick: viewModel.currentTrick,
                            lastPlay: viewModel.lastPlay,
                            passCount: viewModel.gameState.passCount,
                            players: viewModel.gameState.players
                        )
                        .frame(height: 90)
                        
                        // Current player (bottom)
                        PlayerView(
                            player: viewModel.currentPlayer,
                            position: .bottom,
                            isCurrentPlayer: true
                        )
                        .padding(.vertical, 2)
                        
                        // Action buttons
                        HStack(spacing: 8) {
                            Button(action: { viewModel.passTurn() }) {
                                HStack(spacing: 2) {
                                    Image(systemName: "hand.raised.fill")
                                        .font(.caption2)
                                    Text("Pass")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.red]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: .orange.opacity(0.3), radius: 3, x: 0, y: 2)
                            }
                            .disabled(viewModel.selectedCards.isEmpty)
                            
                            Button(action: { viewModel.playSelectedCards() }) {
                                HStack(spacing: 2) {
                                    Image(systemName: "play.fill")
                                        .font(.caption2)
                                    Text("Play")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: viewModel.selectedCards.isEmpty ? [Color.gray, Color.gray.opacity(0.7)] : [Color.green, Color.blue]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: viewModel.selectedCards.isEmpty ? .clear : .green.opacity(0.3), radius: 3, x: 0, y: 2)
                            }
                            .disabled(viewModel.selectedCards.isEmpty)
                        }
                        .padding(.vertical, 2)
                        
                        // Player's cards - horizontal scroll
                        if viewModel.gamePhase == .active {
                            CardHandView(
                                cards: viewModel.sortedPlayerHand,
                                selectedCards: viewModel.selectedCards,
                                onCardTap: { card in
                                    viewModel.toggleCardSelection(card)
                                }
                            )
                            .padding(.bottom, 4)
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
                    .frame(width: 60)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Temporary message overlay
                if viewModel.showingTemporaryMessage {
                    VStack {
                        Spacer()
                        Text(viewModel.temporaryMessage)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(20)
                            .transition(.opacity.combined(with: .scale))
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
    let passCount: Int
    let players: [Player]
    
    var body: some View {
        ZStack {
            // Wooden table background (like the reference app)
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.2), // Lighter wood
                            Color(red: 0.4, green: 0.2, blue: 0.1)  // Darker wood
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.3, green: 0.15, blue: 0.05), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
            
            VStack(spacing: 6) {
                // Pass count indicator
                if passCount > 0 {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.orange)
                        Text("\(passCount) passed")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
                }
                
                // Current trick with stacking effect
                if !currentTrick.isEmpty {
                    VStack(spacing: 4) {
                        Text("Current Trick")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        ZStack {
                            // Background cards (older cards with blur effect)
                            if currentTrick.count > 1 {
                                HStack(spacing: -8) {
                                    ForEach(Array(currentTrick.dropLast().enumerated()), id: \.offset) { index, card in
                                        CardView(card: card, isPlayable: false)
                                            .scaleEffect(0.4)
                                            .blur(radius: 1.5)
                                            .opacity(0.6)
                                            .offset(x: CGFloat(index * 2), y: CGFloat(index * 1))
                                    }
                                }
                            }
                            
                            // Foreground card (most recent play)
                            if let lastCard = currentTrick.last {
                                CardView(card: lastCard, isPlayable: false)
                                    .scaleEffect(0.5)
                                    .offset(x: CGFloat((currentTrick.count - 1) * 2), y: CGFloat((currentTrick.count - 1) * 1))
                            }
                        }
                        .frame(maxHeight: 45)
                    }
                }
                
                // Last play with player info
                if let lastPlay = lastPlay {
                    VStack(spacing: 4) {
                        HStack {
                            Text("Last Play")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                            
                            if let lastPlayer = players.first(where: { $0.id == lastPlay.playerId }) {
                                Text("by \(lastPlayer.displayName)")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        // Last play cards with slight overlap
                        HStack(spacing: -6) {
                            ForEach(lastPlay.cards, id: \.id) { card in
                                CardView(card: card, isPlayable: false)
                                    .scaleEffect(0.4)
                            }
                        }
                        .frame(maxHeight: 35)
                        
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
    @Published var temporaryMessage = ""
    @Published var showingTemporaryMessage = false
    
    private let gameEngine = GameEngine()
    private let soundManager = SoundManager.shared
    private let aiPlayers: [AIPlayer] = [
        AIPlayer(difficulty: .medium),
        AIPlayer(difficulty: .medium),
        AIPlayer(difficulty: .hard)
    ]
    private var gameTimer: Timer?
    private var aiHands: [[Card]] = [] // Store actual AI hands
    
    // MARK: - Temporary Message System
    
    private func showTemporaryMessage(_ message: String, duration: TimeInterval = 2.0) {
        temporaryMessage = message
        showingTemporaryMessage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.showingTemporaryMessage = false
        }
    }
    
    // MARK: - Card Organization
    
    /// Sorts cards by rank then suit (like the reference Pusoy Dos app)
    private func sortCardsForDisplay(_ cards: [Card]) -> [Card] {
        return cards.sorted { card1, card2 in
            // First sort by rank (2 is highest, 3 is lowest in Pusoy Dos)
            if card1.rank.numericValue != card2.rank.numericValue {
                return card1.rank.numericValue < card2.rank.numericValue
            }
            // Then sort by suit (Clubs < Spades < Hearts < Diamonds)
            return card1.suit.suitValue < card2.suit.suitValue
        }
    }
    
    // Computed properties for players
    var currentPlayer: Player {
        return gameState.players[0] // Human player is always seat 0
    }
    
    /// Player's hand sorted for display (like the reference Pusoy Dos app)
    var sortedPlayerHand: [Card] {
        return sortCardsForDisplay(playerHand)
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
        aiHands = Array(hands[1...3]) // Store AI hands (seats 1-3)
        
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
            lastPlay = gameState.lastPlay
            
            // Remove cards from hand
            playerHand.removeAll { card in
                selectedCards.contains { $0 == card }
            }
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
            advanceTurn()
        }
    }
    
    func passTurn() {
        guard gameState.turnPlayer == 0 else { return } // Only human player
        
        gameState = gameState.withUpdatedPassCount(gameState.passCount + 1)
        
        // Show pass message
        showTemporaryMessage("You passed")
        
        // Check if trick should be cleared
        if gameState.shouldClearTrick {
            gameState = gameState.withTrickCleared()
            currentTrick = gameState.currentTrick
            lastPlay = nil // Clear last play when trick is cleared
            soundManager.playTrickClear()
            showTemporaryMessage("Trick cleared! New round starts")
        } else {
            soundManager.playCardPass()
        }
        
        advanceTurn()
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
            let aiPlayer = gameState.players[gameState.turnPlayer]
            showTemporaryMessage("\(aiPlayer.displayName) passed")
            
            gameState = gameState.withUpdatedPassCount(gameState.passCount + 1)
            
            if gameState.shouldClearTrick {
                gameState = gameState.withTrickCleared()
                currentTrick = gameState.currentTrick
                lastPlay = nil // Clear last play when trick is cleared
                showTemporaryMessage("Trick cleared! New round starts")
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
                let aiPlayer = gameState.players[gameState.turnPlayer]
                let play = Play(
                    cards: cards,
                    handType: validation.handType!,
                    playerId: gameState.players[gameState.turnPlayer].id
                )
                
                gameState = gameState.withNewPlay(play)
                currentTrick = gameState.currentTrick
                lastPlay = gameState.lastPlay
                
                // Show what AI played
                showTemporaryMessage("\(aiPlayer.displayName) played \(validation.handType!.displayName)")
                
                // Remove played cards from AI hand
                let aiIndex = gameState.turnPlayer - 1
                aiHands[aiIndex].removeAll { card in
                    cards.contains { $0 == card }
                }
                
                // Update AI player card count
                let newCardCount = aiHands[aiIndex].count
                gameState.players[gameState.turnPlayer].updateCardsRemaining(newCardCount)
                
                // Check for AI win
                if newCardCount == 0 {
                    endGame(winner: gameState.players[gameState.turnPlayer].id)
                    return
                }
            }
        }
        
        advanceTurn()
    }
    
    private func getAIHand(for seatNumber: Int) -> [Card] {
        // Return the actual AI hand for the seat
        let aiIndex = seatNumber - 1 // Convert seat number to AI array index
        guard aiIndex >= 0 && aiIndex < aiHands.count else {
            return []
        }
        return aiHands[aiIndex]
    }
    
    private func advanceTurn() {
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
        aiHands = [] // Reset AI hands
        
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