//
//  GraniteModuleManager.swift
//  ios
//
//  여러 Granite React Native 모듈을 관리하는 매니저 클래스
//

import UIKit
import React

/**
 * 여러 Granite RN 앱을 관리하는 매니저 클래스
 * 각 RN 앱은 독립적인 번들을 가지며, 메모리 효율적으로 로드/언로드됩니다.
 */
class GraniteModuleManager {
    
    static let shared = GraniteModuleManager()
    
    // RN 브릿지들을 저장하는 딕셔너리
    private var bridges: [String: RCTBridge] = [:]
    
    // 현재 활성화된 RN 뷰 컨트롤러들
    private var activeViewControllers: [String: UIViewController] = [:]
    
    private init() {}
    
    /**
     * 지원하는 Granite 모듈들
     */
    enum GraniteModule: String, CaseIterable {
        case home = "home"
        case login = "login"
        case profile = "profile"
        
        var bundleName: String {
            return "\(self.rawValue)"
        }
        
        var appName: String {
            return self.rawValue
        }
        
        var bundleURL: URL? {
            // 개발 모드에서는 Metro 서버에서 번들 로드
            #if DEBUG
            let port = self.getDevPort()
            // React Native 표준 방식으로 번들 URL 생성
            let bundleURLProvider = RCTBundleURLProvider.sharedSettings()
            bundleURLProvider?.jsLocation = "localhost:\(port)"
            return bundleURLProvider?.jsBundleURL(forBundleRoot: "index")
            #else
            // 프로덕션 모드에서는 번들 파일에서 로드
            return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
            #endif
        }
        
        private func getDevPort() -> Int {
            // 각 앱마다 다른 포트 사용 (충돌 방지)
            switch self {
            case .home: return 8081
            case .login: return 8082
            case .profile: return 8083
            }
        }
    }
    
    /**
     * 특정 Granite 모듈의 RCTBridge를 생성하거나 가져옵니다.
     */
    func getBridge(for module: GraniteModule) -> RCTBridge {
        if let existingBridge = bridges[module.rawValue] {
            return existingBridge
        }
        
        guard let bundleURL = module.bundleURL else {
            fatalError("Bundle URL not found for module: \(module.rawValue)")
        }
        
        let bridge = RCTBridge(
            bundleURL: bundleURL,
            moduleProvider: nil,
            launchOptions: nil
        )
        
        guard let safeBridge = bridge else {
            fatalError("Failed to create RCTBridge for module: \(module.rawValue)")
        }
        
        bridges[module.rawValue] = safeBridge
        return safeBridge
    }
    
    /**
     * Granite RN 뷰 컨트롤러를 생성합니다.
     */
    func createViewController(for module: GraniteModule, 
                            initialProperties: [String: Any]? = nil) -> UIViewController {
        
        let bridge = getBridge(for: module)
        
        let rootView = RCTRootView(
            bridge: bridge,
            moduleName: module.appName, // 각 모듈별 동적 앱 이름 사용
            initialProperties: initialProperties
        )
        
        let viewController = UIViewController()
        viewController.view = rootView
        viewController.title = module.rawValue.capitalized
        
        // 활성 뷰 컨트롤러 추적
        activeViewControllers[module.rawValue] = viewController
        
        return viewController
    }
    
    /**
     * 특정 모듈의 브릿지를 종료하고 메모리를 해제합니다.
     */
    func destroyModule(_ module: GraniteModule) {
        // 브릿지 무효화
        if let bridge = bridges[module.rawValue] {
            bridge.invalidate()
            bridges.removeValue(forKey: module.rawValue)
        }
        
        // 뷰 컨트롤러 참조 제거
        activeViewControllers.removeValue(forKey: module.rawValue)
    }
    
    /**
     * 모든 RN 모듈을 정리합니다.
     */
    func destroyAllModules() {
        for (_, bridge) in bridges {
            bridge.invalidate()
        }
        
        bridges.removeAll()
        activeViewControllers.removeAll()
    }
    
    /**
     * 현재 활성화된 모듈 목록을 반환합니다.
     */
    func getActiveModules() -> [String] {
        return Array(activeViewControllers.keys)
    }
    
    /**
     * 안전한 방식으로 현재 활성화된 window를 반환합니다.
     */
    private var activeWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    /**
     * 현재 최상위 뷰 컨트롤러를 안전하게 반환합니다.
     */
    private var topViewController: UIViewController? {
        guard let window = activeWindow else { return nil }
        return topViewController(from: window.rootViewController)
    }
    
    /**
     * 뷰 컨트롤러 계층에서 최상위 뷰 컨트롤러를 찾습니다.
     */
    private func topViewController(from viewController: UIViewController?) -> UIViewController? {
        if let presentedViewController = viewController?.presentedViewController {
            return topViewController(from: presentedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        }
        
        if let tabBarController = viewController as? UITabBarController {
            return topViewController(from: tabBarController.selectedViewController)
        }
        
        return viewController
    }
    
    /**
     * 개발 모드에서 핫 리로딩을 위한 메서드
     */
    func reloadModule(_ module: GraniteModule) {
        destroyModule(module)
        // 새로운 브릿지는 다음 getBridge 호출 시 생성됩니다
    }
    
    /**
     * 안전한 방식으로 Granite 모듈을 모달로 표시합니다.
     */
    func presentModule(_ module: GraniteModule, 
                      animated: Bool = true, 
                      initialProperties: [String: Any]? = nil) {
        guard let topVC = topViewController else {
            print("⚠️ No top view controller found to present module: \(module.rawValue)")
            return
        }
        
        topVC.presentGraniteModule(module, animated: animated, initialProperties: initialProperties)
    }
    
    /**
     * 안전한 방식으로 Granite 모듈을 네비게이션으로 푸시합니다.
     */
    func pushModule(_ module: GraniteModule, 
                   initialProperties: [String: Any]? = nil) {
        guard let topVC = topViewController else {
            print("⚠️ No top view controller found to push module: \(module.rawValue)")
            return
        }
        
        topVC.pushGraniteModule(module, initialProperties: initialProperties)
    }
}

// MARK: - Extensions for easy access

extension UIViewController {
    /**
     * 편리한 Granite 모듈 생성 메서드
     */
    func presentGraniteModule(_ module: GraniteModuleManager.GraniteModule, 
                             animated: Bool = true, 
                             initialProperties: [String: Any]? = nil) {
        let graniteVC = GraniteModuleManager.shared.createViewController(
            for: module, 
            initialProperties: initialProperties
        )
        
        let navController = UINavigationController(rootViewController: graniteVC)
        present(navController, animated: animated)
    }
    
    /**
     * 네비게이션으로 Granite 모듈 푸시
     */
    func pushGraniteModule(_ module: GraniteModuleManager.GraniteModule, 
                          initialProperties: [String: Any]? = nil) {
        let graniteVC = GraniteModuleManager.shared.createViewController(
            for: module, 
            initialProperties: initialProperties
        )
        
        navigationController?.pushViewController(graniteVC, animated: true)
    }
}