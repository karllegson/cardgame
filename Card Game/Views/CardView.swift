//
//  CardView.swift
//  Vector: Pusoy Dos
//
//  Created by Karl on 10/2/25.
//

import SwiftUI

/// Beautiful card view for displaying playing cards
struct CardView: View {
    let card: Card
    let isPlayable: Bool
    let isSelected: Bool
    let onTap: (() -> Void)?
    
    init(card: Card, isPlayable: Bool = true, isSelected: Bool = false, onTap: (() -> Void)? = nil) {
        self.card = card
        self.isPlayable = isPlayable
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            if isPlayable {
                onTap?()
            }
        }) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white,
                                Color(red: 0.98, green: 0.98, blue: 0.98)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.blue : Color.black.opacity(0.2),
                                lineWidth: isSelected ? 3 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? .blue.opacity(0.5) : .black.opacity(0.2),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
                
                VStack(spacing: 4) {
                    // Top rank and suit
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.rank.displayName)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(card.suit.swiftUIColor)
                            
                            Image(systemName: card.suit.systemSymbol)
                                .font(.system(size: 12))
                                .foregroundColor(card.suit.swiftUIColor)
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Center large suit
                    Image(systemName: card.suit.systemSymbol)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(card.suit.swiftUIColor)
                    
                    Spacer()
                    
                    // Bottom rank and suit (upside down)
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Image(systemName: card.suit.systemSymbol)
                                .font(.system(size: 12))
                                .foregroundColor(card.suit.swiftUIColor)
                                .rotationEffect(.degrees(180))
                            
                            Text(card.rank.displayName)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(card.suit.swiftUIColor)
                                .rotationEffect(.degrees(180))
                        }
                    }
                }
                .padding(8)
            }
        }
        .frame(width: 60, height: 84)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .offset(y: isSelected ? -10 : 0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .disabled(!isPlayable)
    }
}

/// Beautiful card hand view for landscape
struct CardHandView: View {
    let cards: [Card]
    let selectedCards: Set<Card>
    let onCardTap: (Card) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -20) {
                ForEach(cards, id: \.id) { card in
                    CardView(
                        card: card,
                        isPlayable: true,
                        isSelected: selectedCards.contains(card),
                        onTap: { onCardTap(card) }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 100)
    }
}

// MARK: - Card Extensions

extension Suit {
    var swiftUIColor: Color {
        switch self {
        case .hearts, .diamonds:
            return .red
        case .clubs, .spades:
            return .black
        }
    }
    
    var systemSymbol: String {
        switch self {
        case .hearts:
            return "suit.heart.fill"
        case .diamonds:
            return "suit.diamond.fill"
        case .clubs:
            return "suit.club.fill"
        case .spades:
            return "suit.spade.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack {
            CardView(card: Card(suit: .hearts, rank: .ace))
            CardView(card: Card(suit: .spades, rank: .king), isSelected: true)
            CardView(card: Card(suit: .diamonds, rank: .queen))
            CardView(card: Card(suit: .clubs, rank: .jack))
        }
        
        CardHandView(
            cards: [
                Card(suit: .hearts, rank: .ace),
                Card(suit: .spades, rank: .king),
                Card(suit: .diamonds, rank: .queen),
                Card(suit: .clubs, rank: .jack),
                Card(suit: .hearts, rank: .ten)
            ],
            selectedCards: [Card(suit: .spades, rank: .king)],
            onCardTap: { _ in }
        )
    }
    .padding()
    .background(Color.green.opacity(0.3))
}