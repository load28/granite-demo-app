//
//  GraniteManager.swift
//  ios
//
//  Central manager for Granite React Native integration
//

import Foundation
import React

class GraniteManager: NSObject {
    
    // MARK: - Singleton
    
    static let shared = GraniteManager()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Properties
    
    private var bridge: RCTBridge?
    private var isInitialized = false
    
    // MARK: - Public Methods
    
    /// Granite 매니저 초기화
    func initialize(bundleURL: URL? = nil) {
        guard !isInitialized else {
            print("Granite Manager is already initialized")
            return
        }
        
        let jsCodeLocation: URL
        
        if let bundleURL = bundleURL {
            jsCodeLocation = bundleURL
        } else {
            // 개발 모드에서는 Metro bundler에서 로드
            #if DEBUG
            jsCodeLocation = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
            #else
            // 프로덕션에서는 번들된 파일에서 로드
            jsCodeLocation = Bundle.main.url(forResource: "main", withExtension: "jsbundle")!
            #endif
        }
        
        bridge = RCTBridge(bundleURL: jsCodeLocation, moduleProvider: nil, launchOptions: nil)
        isInitialized = true
        
        print("Granite Manager initialized with bundle URL: \(jsCodeLocation)")
    }
    
    /// Granite 앱 생성 및 표시
    func presentGraniteApp(
        from viewController: UIViewController,
        appName: String,
        scheme: String = "granite://rn",
        initialProps: [String: Any] = [:],
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let bridge = bridge else {
            print("Granite Error: Manager is not initialized. Call initialize() first.")
            return
        }
        
        guard let graniteViewController = GraniteViewController.createGraniteApp(
            appName: appName,
            scheme: scheme,
            initialProps: initialProps,
            bridge: bridge
        ) else {
            print("Granite Error: Failed to create Granite app")
            return
        }
        
        DispatchQueue.main.async {
            if let navigationController = viewController.navigationController {
                // Navigation Controller가 있으면 push
                navigationController.pushViewController(graniteViewController, animated: animated)
                completion?()
            } else {
                // 없으면 modal presentation
                let nav = UINavigationController(rootViewController: graniteViewController)
                viewController.present(nav, animated: animated, completion: completion)
            }
        }
    }
    
    /// Granite 앱을 새로운 Navigation Controller로 표시
    func presentGraniteAppModally(
        from viewController: UIViewController,
        appName: String,
        scheme: String = "granite://rn",
        initialProps: [String: Any] = [:],
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let bridge = bridge else {
            print("Granite Error: Manager is not initialized. Call initialize() first.")
            return
        }
        
        guard let graniteViewController = GraniteViewController.createGraniteApp(
            appName: appName,
            scheme: scheme,
            initialProps: initialProps,
            bridge: bridge
        ) else {
            print("Granite Error: Failed to create Granite app")
            return
        }
        
        DispatchQueue.main.async {
            let nav = UINavigationController(rootViewController: graniteViewController)
            nav.modalPresentationStyle = .fullScreen
            viewController.present(nav, animated: animated, completion: completion)
        }
    }
    
    /// Bridge 인스턴스 반환
    func getBridge() -> RCTBridge? {
        return bridge
    }
    
    /// 초기화 상태 확인
    func isReady() -> Bool {
        return isInitialized && bridge != nil
    }
}

// MARK: - Convenience Extensions

extension UIViewController {
    
    /// 현재 ViewController에서 Granite 앱 표시
    func showGraniteApp(
        appName: String,
        scheme: String = "granite://rn",
        initialProps: [String: Any] = [:],
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        GraniteManager.shared.presentGraniteApp(
            from: self,
            appName: appName,
            scheme: scheme,
            initialProps: initialProps,
            animated: animated,
            completion: completion
        )
    }
    
    /// 현재 ViewController에서 Granite 앱을 모달로 표시
    func showGraniteAppModally(
        appName: String,
        scheme: String = "granite://rn",
        initialProps: [String: Any] = [:],
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        GraniteManager.shared.presentGraniteAppModally(
            from: self,
            appName: appName,
            scheme: scheme,
            initialProps: initialProps,
            animated: animated,
            completion: completion
        )
    }
}