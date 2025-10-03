//
//  Card_GameApp.swift
//  Card Game
//
//  Created by Karl on 10/2/25
//

import SwiftUI

@main
struct Card_GameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Force landscape orientation
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                }
        }
    }
}
