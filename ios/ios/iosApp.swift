//
//  iosApp.swift
//  ios
//
//  Created by seo minyong on 9/9/25.
//

import SwiftUI

@main
struct iosApp: App {
    
    // UIKit AppDelegate를 SwiftUI App에 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
