//
//  GameResultsView.swift
//  Vector: Pusoy Dos
//
//  Created by Karl on 10/2/25.
//

import SwiftUI

/// View showing game results and statistics
struct GameResultsView: View {
    let gameStats: GameStats
    let players: [Player]
    let onRematch: () -> Void
    let onNewGame: () -> Void
    let onBackToHome: () -> Void
    
    @State private var showingStats = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    
                    Text("Game Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Duration: \(formatDuration(gameStats.duration))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Winner announcement
                VStack(spacing: 12) {
                    Text("Winner")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if let winner = players.first(where: { $0.id == gameStats.winner }) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(.yellow.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(winner.displayName.prefix(1)).uppercased())
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                )
                            
                            Text(winner.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .background(.yellow.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                
                // Final scores
                VStack(alignment: .leading, spacing: 12) {
                    Text("Final Scores")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ForEach(sortedPlayers, id: \.id) { player in
                        HStack {
                            Text(player.displayName)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(gameStats.finalScores[player.id] ?? 0) cards")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(player.id == gameStats.winner ? .green : .primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(player.id == gameStats.winner ? .green.opacity(0.1) : .gray.opacity(0.1))
                        )
                    }
                }
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button("Rematch") {
                        onRematch()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    HStack(spacing: 12) {
                        Button("New Game") {
                            onNewGame()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Home") {
                            onBackToHome()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Computed Properties
    
    private var sortedPlayers: [Player] {
        return players.sorted { player1, player2 in
            let score1 = gameStats.finalScores[player1.id] ?? 0
            let score2 = gameStats.finalScores[player2.id] ?? 0
            return score1 < score2 // Lower score (fewer cards) is better
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// View for displaying game statistics
struct GameStatsView: View {
    let gameStats: GameStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game Statistics")
                .font(.headline)
            
            VStack(spacing: 12) {
                StatRow(title: "Total Plays", value: "\(gameStats.totalPlays)")
                StatRow(title: "Total Passes", value: "\(gameStats.totalPasses)")
                StatRow(title: "Duration", value: formatDuration(gameStats.duration))
                StatRow(title: "Average Play Time", value: formatDuration(gameStats.duration / Double(gameStats.totalPlays)))
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// Row for displaying a statistic
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

#Preview {
    GameResultsView(
        gameStats: GameStats(
            gameId: UUID(),
            duration: 180, // 3 minutes
            totalPlays: 25,
            totalPasses: 8,
            winner: UUID(),
            finalScores: [
                UUID(): 0,  // Winner
                UUID(): 3,  // Second place
                UUID(): 7,  // Third place
                UUID(): 3   // Fourth place
            ]
        ),
        players: [
            Player(displayName: "You", seatNumber: 0, cardsRemaining: 0),
            Player(displayName: "Alex", seatNumber: 1, cardsRemaining: 3),
            Player(displayName: "Sam", seatNumber: 2, cardsRemaining: 7),
            Player(displayName: "Jordan", seatNumber: 3, cardsRemaining: 3)
        ],
        onRematch: {},
        onNewGame: {},
        onBackToHome: {}
    )
}
