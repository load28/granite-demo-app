//
//  GraniteViewController.swift
//  ios
//
//  UIViewController wrapper for Granite React Native screens
//

import UIKit
import React

class GraniteViewController: UIViewController {
    
    // MARK: - Properties
    
    private var rootView: RCTRootView?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Granite 앱이 표시될 때 상태 업데이트
        NotificationCenter.default.post(
            name: NSNotification.Name("GraniteViewWillAppear"),
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Granite 앱이 숨겨질 때 상태 업데이트
        NotificationCenter.default.post(
            name: NSNotification.Name("GraniteViewWillDisappear"),
            object: nil
        )
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        // 네비게이션 바 기본 설정
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // 뒤로 가기 버튼 설정
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "닫기",
            style: .plain,
            target: self,
            action: #selector(closeGraniteView)
        )
    }
    
    // MARK: - Actions
    
    @objc
    private func closeGraniteView() {
        // Granite 모듈의 closeView 호출
        if let bridge = (view as? RCTRootView)?.bridge {
            let graniteModule = bridge.module(for: GraniteModule.self) as? GraniteModule
            graniteModule?.closeView()
        } else {
            // Fallback: 직접 닫기
            if let navigationController = navigationController {
                navigationController.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Public Methods
    
    func updateInitialProperties(_ properties: [String: Any]) {
        if let rootView = view as? RCTRootView {
            rootView.appProperties = properties
        }
    }
}

// MARK: - Granite Integration Extension

extension GraniteViewController {
    
    /// Granite 앱을 생성하고 표시하는 팩토리 메서드
    static func createGraniteApp(
        appName: String,
        scheme: String = "granite://rn",
        initialProps: [String: Any] = [:],
        bridge: RCTBridge
    ) -> GraniteViewController? {
        
        // GraniteModule에 스키마 설정
        if let graniteModule = bridge.module(for: GraniteModule.self) as? GraniteModule {
            graniteModule.setScheme(scheme)
            graniteModule.configureBridge(bridge)
        }
        
        // RCTRootView 생성
        let rootView = RCTRootView(
            bridge: bridge,
            moduleName: appName,
            initialProperties: initialProps
        )
        
        // ViewController 생성 및 설정
        let viewController = GraniteViewController()
        viewController.view = rootView
        viewController.title = appName
        viewController.rootView = rootView
        
        return viewController
    }
}