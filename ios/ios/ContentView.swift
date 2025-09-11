//
//  ContentView.swift
//  ios
//
//  Created by seo minyong on 9/9/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @State private var isGraniteInitialized = true // GraniteModuleManager는 즉시 사용 가능
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text("iOS 네이티브 앱")
                    .font(.title)
                
                Text("✅ Granite 모노레포 준비완료")
                    .foregroundColor(.green)
                
                Text("활성 모듈: \(GraniteModuleManager.shared.getActiveModules().joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    // Home 앱 버튼들
                    HStack(spacing: 12) {
                        Button("Home") {
                            openGraniteModule(.home)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Home (모달)") {
                            openGraniteModuleModally(.home)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    // Login 앱 버튼들
                    HStack(spacing: 12) {
                        Button("Login") {
                            openGraniteModule(.login)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Login (모달)") {
                            openGraniteModuleModally(.login)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    // Profile 앱 버튼들
                    HStack(spacing: 12) {
                        Button("Profile") {
                            openGraniteModule(.profile)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Profile (모달)") {
                            openGraniteModuleModally(.profile)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Divider()
                    
                    // 관리 버튼들
                    HStack(spacing: 12) {
                        Button("모든 모듈 정리") {
                            cleanupAllModules()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .navigationTitle("Granite 모노레포")
        }
    }
    
    // MARK: - Private Methods
    
    /**
     * 특정 Granite 모듈을 네비게이션으로 열기
     */
    private func openGraniteModule(_ module: GraniteModuleManager.GraniteModule) {
        let initialProps: [String: Any] = [
            "userId": "ios_user_\(UUID().uuidString.prefix(8))",
            "source": "native_app_navigation",
            "module": module.rawValue
        ]
        
        GraniteModuleManager.shared.pushModule(module, initialProperties: initialProps)
    }
    
    /**
     * 특정 Granite 모듈을 모달로 열기
     */
    private func openGraniteModuleModally(_ module: GraniteModuleManager.GraniteModule) {
        let initialProps: [String: Any] = [
            "userId": "ios_user_\(UUID().uuidString.prefix(8))",
            "source": "native_app_modal",
            "module": module.rawValue
        ]
        
        GraniteModuleManager.shared.presentModule(module, initialProperties: initialProps)
    }
    
    /**
     * 모든 활성 모듈 정리
     */
    private func cleanupAllModules() {
        GraniteModuleManager.shared.destroyAllModules()
    }
}

#Preview {
    ContentView()
}
