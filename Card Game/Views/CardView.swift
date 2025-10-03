//
//  CardView.swift
//  Vector: Pusoy Dos
//
//  Created by Karl on 10/2/25.
//

import SwiftUI

/// A SwiftUI view representing a playing card
struct CardView: View {
    let card: Card
    let isSelected: Bool
    let isPlayable: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    init(
        card: Card,
        isSelected: Bool = false,
        isPlayable: Bool = true,
        onTap: @escaping () -> Void = {}
    ) {
        self.card = card
        self.isSelected = isSelected
        self.isPlayable = isPlayable
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackgroundColor)
                    .stroke(cardBorderColor, lineWidth: 2)
                    .frame(width: 60, height: 84)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .offset(y: isSelected ? -10 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isSelected)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
                
                // Card content
                VStack(spacing: 2) {
                    // Top rank and suit
                    HStack {
                        Text(card.rank.displayName)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(card.suit.color == .red ? .red : .black)
                        
                        Spacer()
                        
                        Text(card.suit.symbol)
                            .font(.system(size: 10))
                            .foregroundColor(card.suit.color == .red ? .red : .black)
                    }
                    
                    Spacer()
                    
                    // Center suit symbol
                    Text(card.suit.symbol)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(card.suit.color == .red ? .red : .black)
                    
                    Spacer()
                    
                    // Bottom rank and suit (rotated)
                    HStack {
                        Text(card.suit.symbol)
                            .font(.system(size: 10))
                            .foregroundColor(card.suit.color == .red ? .red : .black)
                            .rotationEffect(.degrees(180))
                        
                        Spacer()
                        
                        Text(card.rank.displayName)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(card.suit.color == .red ? .red : .black)
                            .rotationEffect(.degrees(180))
                    }
                }
                .padding(4)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isPlayable)
        .opacity(isPlayable ? 1.0 : 0.5)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    // MARK: - Computed Properties
    
    private var cardBackgroundColor: Color {
        if isSelected {
            return .blue.opacity(0.2)
        } else {
            return .white
        }
    }
    
    private var cardBorderColor: Color {
        if isSelected {
            return .blue
        } else if isPlayable {
            return .gray.opacity(0.3)
        } else {
            return .gray.opacity(0.1)
        }
    }
}

/// A view for displaying a card back (face down)
struct CardBackView: View {
    let width: CGFloat
    let height: CGFloat
    
    init(width: CGFloat = 60, height: CGFloat = 84) {
        self.width = width
        self.height = height
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.8), .blue.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .stroke(.blue.opacity(0.3), lineWidth: 2)
            .frame(width: width, height: height)
            .overlay(
                // Card back pattern
                VStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(0..<2, id: \.self) { col in
                                Circle()
                                    .fill(.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
            )
    }
}

/// A view for displaying a hand of cards in a fan layout
struct CardHandView: View {
    let cards: [Card]
    let selectedCards: Set<Card>
    let onCardTap: (Card) -> Void
    let onPlayCards: () -> Void
    let onPass: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // Cards in horizontal layout for landscape
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -15) {
                    ForEach(cards, id: \.id) { card in
                        CardView(
                            card: card,
                            isSelected: selectedCards.contains(card),
                            isPlayable: true,
                            onTap: { onCardTap(card) }
                        )
                        .scaleEffect(selectedCards.contains(card) ? 1.1 : 1.0)
                        .offset(y: selectedCards.contains(card) ? -10 : 0)
                        .animation(.easeInOut(duration: 0.2), value: selectedCards.contains(card))
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 100)
            
            // Action buttons
            HStack(spacing: 20) {
                Button("Pass") {
                    onPass()
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(selectedCards.isEmpty)
                
                Button("Play") {
                    onPlayCards()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedCards.isEmpty)
            }
        }
    }
}


// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.blue)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.blue.opacity(0.1))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // Single card
        CardView(card: Card(suit: .hearts, rank: .ace))
        
        // Card back
        CardBackView()
        
        // Hand of cards
        CardHandView(
            cards: [
                Card(suit: .hearts, rank: .ace),
                Card(suit: .spades, rank: .king),
                Card(suit: .diamonds, rank: .queen)
            ],
            selectedCards: [],
            onCardTap: { _ in },
            onPlayCards: {},
            onPass: {}
        )
    }
    .padding()
}
