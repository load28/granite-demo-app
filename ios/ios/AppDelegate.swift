//
//  AppDelegate.swift
//  ios
//
//  UIKit 호환 AppDelegate for SwiftUI + React Native 통합
//

import UIKit
import React

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // SwiftUI와 React Native 통합을 위한 초기화
        // window는 SwiftUI에서 자동으로 생성되므로 여기서는 설정하지 않음
        
        return true
    }
    
    // MARK: - React Native 지원을 위한 메서드들
    
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return true
    }
    
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        return true
    }
}

// MARK: - Window 접근을 위한 확장

extension AppDelegate {
    
    /// 현재 활성화된 window를 반환
    var activeWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    /// 루트 뷰 컨트롤러를 반환
    var rootViewController: UIViewController? {
        return activeWindow?.rootViewController
    }
}