//
//  HomeView.swift
//  Vector: Pusoy Dos
//
//  Created by Karl on 10/2/25.
//

import SwiftUI
import Combine

/// The main home screen of the app
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingCreateGame = false
    @State private var showingJoinGame = false
    @State private var showingSettings = false
    @State private var showingGame = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "suit.spade.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Vector: Pusoy Dos")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Classic Filipino Card Game")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Main action buttons
                    VStack(spacing: 16) {
                        // Quick Play button
                        Button(action: {
                            showingGame = true
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Quick Play")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.blue)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isLoading)
                        
                        // Create Private Game button
                        Button(action: {
                            showingCreateGame = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Private Game")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Join Private Game button
                        Button(action: {
                            showingJoinGame = true
                        }) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("Join Private Game")
                            }
                            .font(.headline)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Bottom navigation
                    HStack(spacing: 40) {
                        Button(action: {
                            showingSettings = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                Text("Settings")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Button(action: {
                            // TODO: Navigate to statistics
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.title2)
                                Text("Stats")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Button(action: {
                            // TODO: Navigate to friends
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.title2)
                                Text("Friends")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCreateGame) {
            CreateGameView()
        }
        .sheet(isPresented: $showingJoinGame) {
            JoinGameView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showingGame) {
            GameTableView()
                .preferredColorScheme(.light)
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

/// View for creating a private game
struct CreateGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateGameViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Game settings
                VStack(alignment: .leading, spacing: 16) {
                    Text("Game Settings")
                        .font(.headline)
                    
                    // Game variant selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Game Variant")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Variant", selection: $viewModel.selectedVariant) {
                            ForEach(GameVariant.allCases, id: \.self) { variant in
                                Text(variant.displayName).tag(variant)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Additional options
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Allow Spectators", isOn: $viewModel.allowSpectators)
                        Toggle("Auto-start when full", isOn: $viewModel.autoStart)
                    }
                }
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                // Create button
                Button("Create Game") {
                    viewModel.createGame()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isLoading)
            }
            .padding()
            .navigationTitle("Create Game")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: viewModel.gameCreated) { gameCreated in
            if gameCreated {
                dismiss()
                // TODO: Navigate to lobby
            }
        }
    }
}

/// View for joining a private game
struct JoinGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = JoinGameViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Enter Room Code")
                        .font(.headline)
                    
                    TextField("ABC123", text: $viewModel.roomCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.roomCode) { newValue in
                            // Limit to 6 characters
                            if newValue.count > 6 {
                                viewModel.roomCode = String(newValue.prefix(6))
                            }
                        }
                    
                    Text("Enter the 6-character room code provided by the host")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                // Join button
                Button("Join Game") {
                    viewModel.joinGame()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.roomCode.count != 6 || viewModel.isLoading)
            }
            .padding()
            .navigationTitle("Join Game")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: viewModel.gameJoined) { gameJoined in
            if gameJoined {
                dismiss()
                // TODO: Navigate to lobby
            }
        }
    }
}

/// Placeholder settings view
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                Text("Settings coming soon!")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ViewModels

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showingError = false
    @Published var errorMessage = ""
    
    func startQuickPlay() {
        isLoading = true
        
        // TODO: Implement quick play logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            // TODO: Navigate to game
        }
    }
}

@MainActor
class CreateGameViewModel: ObservableObject {
    @Published var selectedVariant: GameVariant = .classic
    @Published var allowSpectators = false
    @Published var autoStart = true
    @Published var isLoading = false
    @Published var gameCreated = false
    
    func createGame() {
        isLoading = true
        
        // TODO: Implement game creation logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.gameCreated = true
        }
    }
}

@MainActor
class JoinGameViewModel: ObservableObject {
    @Published var roomCode = ""
    @Published var isLoading = false
    @Published var gameJoined = false
    
    func joinGame() {
        isLoading = true
        
        // TODO: Implement join game logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.gameJoined = true
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
