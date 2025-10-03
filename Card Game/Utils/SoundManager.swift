//
//  SoundManager.swift
//  Vector: Pusoy Dos
//
//  Created by Karl on 10/2/25.
//

import AVFoundation
import UIKit
import Combine

/// Manages sound effects and haptic feedback for the game
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var soundEnabled = true
    @Published var hapticsEnabled = true
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        setupAudioSession()
        loadSounds()
    }
    
    // MARK: - Sound Effects
    
    func playCardFlip() {
        playSound("card_flip", volume: 0.3)
        triggerHaptic(.light)
    }
    
    func playCardPlay() {
        playSound("card_play", volume: 0.4)
        triggerHaptic(.medium)
    }
    
    func playCardPass() {
        playSound("card_pass", volume: 0.3)
        triggerHaptic(.light)
    }
    
    func playGameWin() {
        playSound("game_win", volume: 0.6)
        triggerHaptic(.success)
    }
    
    func playGameLose() {
        playSound("game_lose", volume: 0.5)
        triggerHaptic(.error)
    }
    
    func playButtonTap() {
        playSound("button_tap", volume: 0.2)
        triggerHaptic(.light)
    }
    
    func playTurnChange() {
        playSound("turn_change", volume: 0.3)
        triggerHaptic(.light)
    }
    
    func playTrickClear() {
        playSound("trick_clear", volume: 0.4)
        triggerHaptic(.medium)
    }
    
    // MARK: - Haptic Feedback
    
    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard hapticsEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func triggerHaptic(_ style: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(style)
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func loadSounds() {
        let soundFiles = [
            "card_flip", "card_play", "card_pass", "game_win", "game_lose",
            "button_tap", "turn_change", "trick_clear"
        ]
        
        for soundFile in soundFiles {
            if let url = Bundle.main.url(forResource: soundFile, withExtension: "wav") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[soundFile] = player
                } catch {
                    print("Failed to load sound \(soundFile): \(error)")
                }
            }
        }
    }
    
    private func playSound(_ soundName: String, volume: Float = 1.0) {
        guard soundEnabled else { return }
        
        if let player = audioPlayers[soundName] {
            player.volume = volume
            player.currentTime = 0
            player.play()
        }
    }
}

/// Haptic feedback styles for different game events
enum HapticStyle {
    case light
    case medium
    case heavy
    case success
    case error
    case warning
}
