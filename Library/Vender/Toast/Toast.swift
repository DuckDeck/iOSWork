//
//  Toast.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/16.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import KRProgressHUD
class Toast{

    static var isShowing = false
    private static var cancellableLoadingWindow: UIWindow?
    private static var cancellableLoadingViewController: CancellableLoadingViewController?
    
    static func showToast(msg:String) {
       
        DispatchQueue.main.async {
            KRProgressHUD.dismiss()
            self.isShowing = false
            GrandCue.toast(msg)
        }
        
    }
    static func showToast(msg:String,originy:Float) {
        GrandCue.toast(msg, verticalScale: originy)
    }
    
    static func showLoading(txt:String = "加载中..."){
        KRProgressHUD.set(style: .custom(background: UIColor.blue, text: UIColor.red, icon: UIColor.yellow)).showMessage(txt)
        isShowing = true
    }

    /// Shows a loading HUD with a button the user can tap to cancel the underlying work.
    /// - Parameters:
    ///   - txt: Loading message.
    ///   - cancelTitle: Title of the cancellation button.
    ///   - onCancel: Called once after the user dismisses the HUD with the cancellation button.
    static func showLoading(
        txt: String = "加载中...",
        cancelTitle: String = "取消",
        onCancel: @escaping () -> Void
    ) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                showLoading(txt: txt, cancelTitle: cancelTitle, onCancel: onCancel)
            }
            return
        }

        dismissLoading()

        let viewController = CancellableLoadingViewController(
            message: txt,
            cancelTitle: cancelTitle,
            onCancel: onCancel
        )
        let window: UIWindow
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            window = UIWindow(windowScene: windowScene)
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }

        window.rootViewController = viewController
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()
        cancellableLoadingViewController = viewController
        cancellableLoadingWindow = window
        isShowing = true
    }
    
    //    func isShowing() -> Bool {
    //
    //    }
    
    static func dismissLoading() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                dismissLoading()
            }
            return
        }

        KRProgressHUD.dismiss()
        cancellableLoadingViewController?.dismissWithoutCancelling()
        cancellableLoadingViewController = nil
        cancellableLoadingWindow?.isHidden = true
        cancellableLoadingWindow = nil
        isShowing = false
    }
}

private final class CancellableLoadingViewController: UIViewController {
    private let message: String
    private let cancelTitle: String
    private var onCancel: (() -> Void)?

    init(message: String, cancelTitle: String, onCancel: @escaping () -> Void) {
        self.message = message
        self.cancelTitle = cancelTitle
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)

        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle(cancelTitle, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(indicator)
        card.addSubview(messageLabel)
        card.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(greaterThanOrEqualToConstant: 180),
            card.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -48),

            indicator.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            indicator.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            cancelButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
            cancelButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
    }

    func dismissWithoutCancelling() {
        onCancel = nil
    }

    @objc private func cancelTapped() {
        let handler = onCancel
        Toast.dismissLoading()
        handler?()
    }
}
