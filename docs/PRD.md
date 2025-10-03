# Product Requirements Document: Vector: Pusoy Dos

## 1. Vision & Success Metrics

### Vision
Vector: Pusoy Dos is a modern, accessible multiplayer card game that brings the classic Filipino card game to iOS with a clean, Apple-inspired design. The game emphasizes quick matches, social play, and seamless multiplayer experiences.

### Success Metrics
- **DAU (Daily Active Users)**: 1,000+ within 3 months
- **Average Session Duration**: 8-12 minutes per match
- **Retention**: D1: 65%, D7: 35%, D30: 15%
- **Match Completion Rate**: 85%+ (players finish started games)
- **User Rating**: 4.5+ stars on App Store
- **Social Engagement**: 40% of matches are private tables

## 2. Personas & Top User Stories

### Primary Personas

#### **Casual Player (Maria, 28)**
- Plays during commute, lunch breaks
- Wants quick matches with friends
- **User Stories**:
  - As a casual player, I want to join a quick match so I can play during my break
  - As a casual player, I want to invite friends to a private table so we can play together
  - As a casual player, I want to learn the rules as I play so I don't need to read tutorials

#### **Competitive Player (Jose, 35)**
- Plays regularly, wants to improve
- Interested in statistics and progression
- **User Stories**:
  - As a competitive player, I want to see my win rate and statistics
  - As a competitive player, I want to play against skilled opponents
  - As a competitive player, I want to track my improvement over time

#### **Social Player (Ana, 24)**
- Plays for social interaction
- Enjoys voice chat and emojis
- **User Stories**:
  - As a social player, I want to use emojis and reactions during games
  - As a social player, I want to create private tables with custom rules
  - As a social player, I want to add friends and see when they're online

## 3. Core Loop & Rules

### Game Rules (Classic Pusoy Dos)

#### **Setup**
- 4 players, 52-card deck
- Each player gets 13 cards
- Player with 3 of Diamonds starts

#### **Play Mechanics**
- **Singles**: One card (3♦ beats 2♠)
- **Pairs**: Two cards of same rank (A♠A♥ beats K♠K♥)
- **Triples**: Three cards of same rank (7♠7♥7♦ beats 6♠6♥6♦)
- **5-Card Hands**: Straight, Flush, Full House, Four of a Kind, Straight Flush
- **Pass**: Skip turn (allowed anytime)
- **Trick Clear**: After 3 consecutive passes, trick clears, last player to play starts new trick

#### **Winning**
- First player to empty hand wins
- Remaining players ranked by cards left

#### **Togglable Variants**
- **No Pass**: Players must play if they have valid cards
- **Reverse Order**: Play in reverse after each trick
- **Joker Wild**: Include 2 jokers as wild cards
- **Speed Mode**: 10-second turn timer

### Core Loop
1. **Matchmaking** → Join/Create game
2. **Lobby** → Wait for players, customize rules
3. **Gameplay** → Play cards, pass, react
4. **Results** → View scores, rematch option
5. **Return to Home** → Start new game

## 4. Scope by Milestone

### M0: Foundation (4 weeks)
- Basic SwiftUI app structure
- Supabase integration
- Authentication (Apple Sign-In)
- Basic card rendering
- **Acceptance Criteria**: Can create account, see home screen, basic navigation works

### M1: Core Gameplay (6 weeks)
- Card game logic implementation
- Basic multiplayer (4 players)
- Turn-based gameplay
- Pass functionality
- **Acceptance Criteria**: 4 players can play a complete game with all rules

### M2: Polish & UX (4 weeks)
- Animations and transitions
- Haptic feedback
- Sound effects
- Error handling
- **Acceptance Criteria**: Game feels polished, smooth animations, proper feedback

### M3: Social Features (3 weeks)
- Private tables
- Friend system
- Emojis and reactions
- Match history
- **Acceptance Criteria**: Can create private games, add friends, see game history

### M4: Advanced Features (4 weeks)
- Game variants
- Statistics tracking
- Reconnection handling
- Push notifications
- **Acceptance Criteria**: All variants work, stats are accurate, reconnection seamless

### M5: Launch Preparation (3 weeks)
- App Store optimization
- Analytics implementation
- Performance optimization
- Beta testing
- **Acceptance Criteria**: App Store ready, all metrics tracking, performance targets met

## 5. UX Spec

### Key Screens

#### **Home Screen**
- Quick Play button (prominent)
- Create Private Table
- Join Private Table (code input)
- Settings, Statistics, Friends
- **Gestures**: Tap to navigate, swipe for quick actions

#### **Lobby Screen**
- Player slots (4 circles with avatars)
- Game settings (variants, timer)
- Ready/Start button
- Chat area
- **Gestures**: Tap to toggle ready, long press for settings

#### **Table Screen**
- Card hand (bottom, fan layout)
- Play area (center, card stacks)
- Player info (top, left, right)
- Turn indicator
- **Gestures**: 
  - Tap card to select
  - Drag to play
  - Double tap to pass
  - Pinch to zoom cards

#### **In-Game Screen**
- Same as table with overlay
- Timer countdown
- Last play indicator
- Emoji reactions
- **Gestures**: Swipe up for emoji picker, tap for quick reactions

#### **Results Screen**
- Final scores
- Game statistics
- Rematch button
- Share results
- **Gestures**: Tap rematch, swipe to dismiss

### Haptics
- **Card Selection**: Light tap
- **Card Play**: Medium tap
- **Turn Change**: Light tap
- **Game Win**: Success pattern
- **Game Loss**: Failure pattern
- **Error**: Heavy tap

## 6. Multiplayer Spec

### Matchmaking
- **Quick Play**: Join first available game
- **Private Tables**: 6-digit room codes
- **Friend Games**: Direct invitations

### Seat Assignment
- Random assignment for Quick Play
- Host chooses seats in Private Tables
- Spectator mode for full tables

### Reconnection
- 30-second grace period
- Auto-reconnect on app resume
- Bot replacement after timeout
- Rejoin option in match history

### Network Architecture
- **Server-Authoritative**: All game state on server
- **Client Rendering**: UI updates from server events
- **Optimistic Updates**: Immediate UI feedback with rollback
- **Conflict Resolution**: Server state always wins

## 7. Data Model

### Tables

#### **users**
```sql
id: uuid (primary key)
email: text
display_name: text
avatar_url: text
created_at: timestamp
last_seen: timestamp
```

#### **matches**
```sql
id: uuid (primary key)
room_code: text (unique, 6 chars)
host_id: uuid (foreign key to users)
status: text (waiting, active, completed, abandoned)
game_variant: text
created_at: timestamp
started_at: timestamp
completed_at: timestamp
```

#### **match_players**
```sql
id: uuid (primary key)
match_id: uuid (foreign key to matches)
user_id: uuid (foreign key to users)
seat_number: integer (0-3)
status: text (waiting, ready, playing, disconnected)
joined_at: timestamp
```

#### **game_states**
```sql
id: uuid (primary key)
match_id: uuid (foreign key to matches)
turn_player: integer (seat number)
current_trick: jsonb
player_hands: jsonb
play_history: jsonb
pass_count: integer
last_updated: timestamp
```

#### **game_actions**
```sql
id: uuid (primary key)
match_id: uuid (foreign key to matches)
player_id: uuid (foreign key to users)
action_type: text (play, pass, join, leave)
action_data: jsonb
timestamp: timestamp
```

## 8. API & Realtime Events

### HTTP Endpoints

#### **Authentication**
```http
POST /auth/signin
Content-Type: application/json

{
  "apple_token": "string"
}

Response:
{
  "user": {
    "id": "uuid",
    "display_name": "string",
    "avatar_url": "string"
  },
  "access_token": "string"
}
```

#### **Matches**
```http
POST /matches/create
Authorization: Bearer {token}

{
  "variant": "classic",
  "is_private": true
}

Response:
{
  "match_id": "uuid",
  "room_code": "ABC123"
}
```

```http
POST /matches/join
Authorization: Bearer {token}

{
  "room_code": "ABC123"
}

Response:
{
  "match_id": "uuid",
  "seat_number": 1
}
```

### Realtime Events

#### **Match Events**
```json
// Player joined
{
  "type": "player_joined",
  "match_id": "uuid",
  "player": {
    "id": "uuid",
    "display_name": "string",
    "seat_number": 1
  }
}

// Game state update
{
  "type": "game_state_update",
  "match_id": "uuid",
  "game_state": {
    "turn_player": 1,
    "current_trick": [],
    "player_hands": [13, 12, 11, 10],
    "last_play": {
      "player": 0,
      "cards": ["3♦"],
      "type": "single"
    }
  }
}

// Player action
{
  "type": "player_action",
  "match_id": "uuid",
  "player_id": "uuid",
  "action": {
    "type": "play",
    "cards": ["3♦", "3♠"],
    "hand_type": "pair"
  }
}
```

## 9. Error States & Offline Handling

### Error States
- **Network Error**: Show retry button, queue actions
- **Invalid Move**: Highlight valid cards, show error message
- **Player Disconnected**: Show reconnection timer, bot replacement
- **Game Abandoned**: Return to home, show match history

### Offline Handling
- **Queue Actions**: Store actions locally, sync when online
- **Cached Game State**: Show last known state with offline indicator
- **Graceful Degradation**: Disable realtime features, show cached data

### Reconnection Flow
1. Detect network restoration
2. Rejoin active match if possible
3. Sync missed game state
4. Resume normal gameplay

## 10. Analytics & Privacy

### Analytics Events
```swift
// Game events
Analytics.track("match_started", properties: [
  "match_id": matchId,
  "variant": gameVariant,
  "player_count": 4
])

Analytics.track("card_played", properties: [
  "match_id": matchId,
  "card_count": cards.count,
  "hand_type": handType
])

Analytics.track("match_completed", properties: [
  "match_id": matchId,
  "duration": duration,
  "winner": winnerId,
  "cards_remaining": cardsRemaining
])
```

### Privacy
- **Data Collection**: Game statistics, match history, device info
- **User Consent**: Clear opt-in for analytics
- **Data Retention**: 2 years for match data, 30 days for analytics
- **GDPR Compliance**: Data export, deletion requests

## 11. Open Questions & Future

### Open Questions
1. **Monetization**: Free with ads, premium features, or subscription?
2. **Tournament System**: How to implement ranked play?
3. **Cross-Platform**: Android version priority?
4. **AI Opponents**: Difficulty levels for single-player?

### Future Features (Ranked by Priority)
1. **Ranked Play**: ELO system, seasonal rankings
2. **Cosmetics**: Card backs, table themes, avatars
3. **Tournaments**: Scheduled events, brackets
4. **Spectator Mode**: Watch friends play
5. **Replay System**: Review past games
6. **Achievements**: Unlock system, badges
7. **Voice Chat**: In-game communication
8. **Custom Rules**: User-defined variants

## State Diagrams

### Match Lifecycle
```
[Created] → [Waiting] → [Active] → [Completed]
    ↓           ↓           ↓           ↓
[Abandoned] [Abandoned] [Abandoned] [Archived]
```

### Game State Transitions
```
[Deal] → [Play] → [Pass] → [Trick Clear] → [Play]
  ↓        ↓        ↓           ↓           ↓
[Win]   [Pass]   [Play]     [Deal]      [Win]
```

## Sequence Diagram: Play/Pass Flow

```
Player    Client    Server    Other Players
  |         |         |            |
  |--Play-->|         |            |
  |         |--POST-->|            |
  |         |         |--Validate->|
  |         |         |--Update--> |
  |         |<--Event--|            |
  |<--Event-|         |--Event---->|
  |         |         |            |
  |--Pass-->|         |            |
  |         |--POST-->|            |
  |         |         |--Update--> |
  |         |<--Event--|            |
  |<--Event-|         |--Event---->|
```

## Swift State Reducer Example

```swift
struct GameState {
    var players: [Player]
    var currentTrick: [Card]
    var turnPlayer: Int
    var passCount: Int
    var gamePhase: GamePhase
}

enum GameAction {
    case playCards([Card])
    case pass
    case playerJoined(Player)
    case playerLeft(Player)
}

func gameReducer(state: inout GameState, action: GameAction) -> GameState {
    switch action {
    case .playCards(let cards):
        state.currentTrick.append(contentsOf: cards)
        state.turnPlayer = (state.turnPlayer + 1) % 4
        state.passCount = 0
        
    case .pass:
        state.passCount += 1
        state.turnPlayer = (state.turnPlayer + 1) % 4
        
        if state.passCount >= 3 {
            state.currentTrick.removeAll()
            state.passCount = 0
        }
        
    case .playerJoined(let player):
        state.players.append(player)
        
    case .playerLeft(let player):
        state.players.removeAll { $0.id == player.id }
    }
    
    return state
}
```
