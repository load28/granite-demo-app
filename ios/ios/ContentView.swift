//
//  ContentView.swift
//  ios
//
//  Created by seo minyong on 9/9/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @State private var isGraniteInitialized = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text("iOS 네이티브 앱")
                    .font(.title)
                
                if isGraniteInitialized {
                    Text("✅ Granite 초기화 완료")
                        .foregroundColor(.green)
                } else {
                    Text("⏳ Granite 초기화 중...")
                        .foregroundColor(.orange)
                }
                
                VStack(spacing: 12) {
                    Button("Granite RN 앱 열기") {
                        openGraniteApp()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isGraniteInitialized)
                    
                    Button("Granite RN 앱 (모달)") {
                        openGraniteAppModally()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!isGraniteInitialized)
                }
            }
            .padding()
            .navigationTitle("메인화면")
        }
        .onAppear {
            initializeGranite()
        }
    }
    
    // MARK: - Private Methods
    
    private func initializeGranite() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            GraniteManager.shared.initialize()
            isGraniteInitialized = GraniteManager.shared.isReady()
        }
    }
    
    private func openGraniteApp() {
        if let viewController = UIApplication.shared.topViewController {
            viewController.showGraniteApp(
                appName: "rn",
                scheme: "granite://rn",
                initialProps: [
                    "userId": "ios_user_123",
                    "source": "native_app"
                ]
            )
        }
    }
    
    private func openGraniteAppModally() {
        if let viewController = UIApplication.shared.topViewController {
            viewController.showGraniteAppModally(
                appName: "rn",
                scheme: "granite://rn",
                initialProps: [
                    "userId": "ios_user_456",
                    "source": "native_app_modal"
                ]
            )
        }
    }
}

#Preview {
    ContentView()
}
