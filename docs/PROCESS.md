# Engineering Process & Conventions: Vector: Pusoy Dos

## Branch Strategy

### Git Flow
- **Main Branch**: `main` (production-ready code)
- **Feature Branches**: `feature/description` (short-lived, < 3 days)
- **Hotfix Branches**: `hotfix/description` (critical fixes)
- **Release Branches**: `release/v1.0.0` (pre-release stabilization)

### Branch Naming
```bash
feature/card-animations
feature/multiplayer-lobby
hotfix/crash-on-pass
release/v1.0.0
```

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
```

## Code Quality

### SwiftLint Configuration
```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace
  - line_length

opt_in_rules:
  - empty_count
  - force_unwrapping
  - implicitly_unwrapped_optional

line_length:
  warning: 120
  error: 150

function_body_length:
  warning: 50
  error: 100

file_length:
  warning: 400
  error: 1000
```

### Swift Format Rules
```json
{
  "indentation": 4,
  "lineLength": 120,
  "respectsExistingLineBreaks": true,
  "tabWidth": 4,
  "usesTabs": false
}
```

### Coding Guidelines

#### Async/Await Usage
```swift
// ✅ Preferred
func fetchGameState() async throws -> GameState {
    let response = try await networkService.get("/game/state")
    return try JSONDecoder().decode(GameState.self, from: response.data)
}

// ❌ Avoid
func fetchGameState(completion: @escaping (Result<GameState, Error>) -> Void) {
    // Callback-based code
}
```

#### Combine Integration
```swift
// ✅ For UI binding and reactive updates
class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .initial
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        gameStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.gameState, on: self)
            .store(in: &cancellables)
    }
}
```

#### Value Types in GameCore
```swift
// ✅ Immutable game state
struct GameState {
    let players: [Player]
    let currentTrick: [Card]
    let turnPlayer: Int
    
    func withNewPlay(_ cards: [Card]) -> GameState {
        GameState(
            players: players,
            currentTrick: currentTrick + cards,
            turnPlayer: (turnPlayer + 1) % 4
        )
    }
}
```

## Testing Strategy

### Testing Pyramid
- **Unit Tests (70%)**: Business logic, game rules, utilities
- **Integration Tests (20%)**: API integration, database operations
- **UI Tests (10%)**: Critical user flows, accessibility

### Coverage Targets
- **Overall**: 80%+ line coverage
- **GameCore**: 95%+ line coverage
- **Network Layer**: 90%+ line coverage
- **UI Components**: 70%+ line coverage

### Snapshot Testing Policy
```swift
// ✅ Test UI components with snapshots
func testCardView() {
    let card = Card(suit: .hearts, rank: .ace)
    let view = CardView(card: card)
    
    assertSnapshot(matching: view, as: .image)
}
```

### Test Structure
```swift
class GameLogicTests: XCTestCase {
    func testValidPlay() {
        // Given
        let gameState = GameState.initial
        let cards = [Card(suit: .hearts, rank: .ace)]
        
        // When
        let result = gameState.canPlay(cards)
        
        // Then
        XCTAssertTrue(result)
    }
}
```

## CI/CD Pipeline

### GitHub Actions Workflow
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.0'
      
      - name: Install Dependencies
        run: brew install swiftlint swiftformat
      
      - name: Lint
        run: swiftlint lint
      
      - name: Format Check
        run: swiftformat --lint .
      
      - name: Build
        run: xcodebuild -scheme "Card Game" -destination "platform=iOS Simulator,name=iPhone 15" build
      
      - name: Test
        run: xcodebuild -scheme "Card Game" -destination "platform=iOS Simulator,name=iPhone 15" test
      
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
```

### Release Checklist
- [ ] All tests pass
- [ ] Code coverage meets targets
- [ ] Performance benchmarks pass
- [ ] Memory leak tests pass
- [ ] Accessibility audit completed
- [ ] Localization verified
- [ ] App Store metadata updated
- [ ] TestFlight build uploaded
- [ ] Beta testing completed

## Local Development

### Supabase Setup
```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Initialize project
supabase init

# Start local development
supabase start

# Generate types
supabase gen types typescript --local > Types.swift
```

### Environment Configuration
```swift
// Config.swift
enum Environment {
    case development
    case staging
    case production
    
    var supabaseURL: String {
        switch self {
        case .development:
            return "http://localhost:54321"
        case .staging:
            return "https://your-project.supabase.co"
        case .production:
            return "https://your-project.supabase.co"
        }
    }
}
```

### Secrets Management
```swift
// Secrets.swift (not committed)
struct Secrets {
    static let supabaseAnonKey = "your-anon-key"
    static let analyticsKey = "your-analytics-key"
}
```

## Performance & Profiling

### Instruments Checklist
- [ ] **Time Profiler**: Identify slow functions
- [ ] **Allocations**: Check for memory leaks
- [ ] **Leaks**: Detect retain cycles
- [ ] **Energy Log**: Battery usage optimization
- [ ] **Network**: API call efficiency

### Performance Targets
- **App Launch**: < 2 seconds
- **Screen Transitions**: < 300ms
- **Card Animations**: 60 FPS
- **Memory Usage**: < 100MB peak
- **Battery Impact**: Minimal background usage

### Optimization Guidelines
```swift
// ✅ Efficient card rendering
struct CardView: View {
    let card: Card
    
    var body: some View {
        Image(card.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .drawingGroup() // Optimize complex views
    }
}

// ✅ Lazy loading for large lists
LazyVStack {
    ForEach(players) { player in
        PlayerView(player: player)
    }
}
```

## Git Hooks & Commits

### Pre-commit Hook
```bash
#!/bin/sh
# .git/hooks/pre-commit

# Run SwiftLint
swiftlint lint --quiet

# Run SwiftFormat
swiftformat --lint .

# Run tests
xcodebuild test -scheme "Card Game" -destination "platform=iOS Simulator,name=iPhone 15"
```

### Conventional Commits
```bash
# Format: type(scope): description
feat(game): add card animation system
fix(multiplayer): resolve connection timeout
docs(readme): update installation instructions
refactor(ui): simplify card layout logic
test(game): add unit tests for game rules
```

## Architecture Patterns

### MVVM + Repository Pattern
```swift
// View
struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        // UI implementation
    }
}

// ViewModel
class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .initial
    private let gameRepository: GameRepositoryProtocol
    
    init(gameRepository: GameRepositoryProtocol = GameRepository()) {
        self.gameRepository = gameRepository
    }
}

// Repository
protocol GameRepositoryProtocol {
    func fetchGameState() async throws -> GameState
    func playCards(_ cards: [Card]) async throws
}

class GameRepository: GameRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    func fetchGameState() async throws -> GameState {
        // Implementation
    }
}
```

### Dependency Injection
```swift
// Container
class DIContainer {
    static let shared = DIContainer()
    
    lazy var networkService: NetworkServiceProtocol = NetworkService()
    lazy var gameRepository: GameRepositoryProtocol = GameRepository(networkService: networkService)
    
    private init() {}
}
```

## Error Handling

### Error Types
```swift
enum GameError: LocalizedError {
    case invalidMove
    case networkError(Error)
    case gameNotFound
    case playerDisconnected
    
    var errorDescription: String? {
        switch self {
        case .invalidMove:
            return "Invalid card play"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .gameNotFound:
            return "Game not found"
        case .playerDisconnected:
            return "Player disconnected"
        }
    }
}
```

### Error Handling Strategy
```swift
// ✅ Comprehensive error handling
func playCards(_ cards: [Card]) async {
    do {
        try await gameRepository.playCards(cards)
        // Update UI optimistically
    } catch {
        // Handle error gracefully
        showError(error.localizedDescription)
        // Rollback optimistic update
    }
}
```

## Documentation Standards

### Code Documentation
```swift
/// Represents a playing card in the game
/// - Parameters:
///   - suit: The suit of the card (hearts, diamonds, clubs, spades)
///   - rank: The rank of the card (2-10, J, Q, K, A)
struct Card {
    let suit: Suit
    let rank: Rank
    
    /// Determines if this card can beat another card
    /// - Parameter other: The card to compare against
    /// - Returns: True if this card beats the other card
    func beats(_ other: Card) -> Bool {
        // Implementation
    }
}
```

### API Documentation
```swift
/// Game API endpoints for multiplayer functionality
enum GameAPI {
    /// Creates a new game match
    /// - Parameter variant: The game variant to use
    /// - Returns: The created match information
    static func createMatch(variant: GameVariant) async throws -> Match
}
```

This engineering process ensures consistent, high-quality code delivery for Vector: Pusoy Dos while maintaining team productivity and code maintainability.
