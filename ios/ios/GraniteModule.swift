//
//  GraniteModule.swift
//  ios
//
//  Granite TurboModule implementation for iOS
//

import Foundation
import React

@objc(GraniteModule)
class GraniteModule: NSObject, RCTBridgeModule {
    
    @objc public static func moduleName() -> String! {
        return "GraniteModule"
    }
    
    @objc public static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    // MARK: - Properties
    
    @objc public var initialScheme: String = "granite://rn"
    @objc public var bridge: RCTBridge?
    
    // MARK: - TurboModule Interface
    
    @objc public func closeView() {
        DispatchQueue.main.async {
            if let topViewController = UIApplication.shared.topViewController {
                if let navigationController = topViewController.navigationController {
                    navigationController.popViewController(animated: true)
                } else {
                    topViewController.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc public var schemeUri: String {
        return initialScheme
    }
    
    
    // MARK: - Public Methods
    
    @objc public func setScheme(_ scheme: String) {
        self.initialScheme = scheme
    }
    
    @objc public func configureBridge(_ bridge: RCTBridge) {
        self.bridge = bridge
    }
    
    @objc public func createGraniteViewController(
        appName: String,
        initialProps: [String: Any]? = nil
    ) -> UIViewController? {
        
        guard let bridge = self.bridge else {
            print("Granite Error: Bridge is not initialized")
            return nil
        }
        
        let props = initialProps ?? [:]
        
        let rootView = RCTRootView(
            bridge: bridge,
            moduleName: appName,
            initialProperties: props
        )
        
        let viewController = GraniteViewController()
        viewController.view = rootView
        viewController.title = appName
        
        return viewController
    }
}

// MARK: - UIApplication Extension

extension UIApplication {
    var topViewController: UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        var topController = window.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        if let navigationController = topController as? UINavigationController {
            return navigationController.visibleViewController
        }
        
        return topController
    }
}