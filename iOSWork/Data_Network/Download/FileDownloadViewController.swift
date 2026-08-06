//
//  FileDownloadViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2026/8/6.
//

import UIKit

class FileDownloadViewController: UIViewController {
    private let progressContainer = UIView()
    private let progressTitleLabel = UILabel()
    private let progressLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let cancelButton = UIButton(type: .system)
    private var downloadToken: WGMediaFileDownloadToken?
    private var currentProgress: Float = 0
    private var currentSpeed: Int64 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "文件下载", style: .plain, target: self, action: #selector(downloadFile))
        configureProgressView()
    }

    deinit {
        downloadToken?.cancel()
    }

    @objc private func downloadFile() {
        guard downloadToken == nil else { return }

        progressContainer.isHidden = false
        progressView.setProgress(0, animated: false)
        progressTitleLabel.text = "正在下载文件"
        currentProgress = 0
        currentSpeed = 0
        updateProgressLabel()
        cancelButton.isHidden = false
        cancelButton.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = false

        downloadToken = MediaDownloader().downloadFile(
            url: "https://file.bqbbq.com/api/public/dl/wA2P9-st",
            progress: { [weak self] progress in
                self?.updateProgress(progress)
            },
            speed: { [weak self] bytesPerSecond in
                self?.updateSpeed(bytesPerSecond)
            },
            completed: { [weak self] _, error in
                self?.finishDownload(error: error)
            }
        )
    }

    private func configureProgressView() {
        progressContainer.backgroundColor = .secondarySystemBackground
        progressContainer.layer.cornerRadius = 12
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.isHidden = true
        view.addSubview(progressContainer)

        progressTitleLabel.font = .preferredFont(forTextStyle: .headline)
        progressTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        progressLabel.font = .preferredFont(forTextStyle: .subheadline)
        progressLabel.textColor = .secondaryLabel
        progressLabel.textAlignment = .right
        progressLabel.translatesAutoresizingMaskIntoConstraints = false

        progressView.progressTintColor = view.tintColor
        progressView.trackTintColor = .tertiarySystemFill
        progressView.translatesAutoresizingMaskIntoConstraints = false

        cancelButton.setTitle("取消下载", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelDownload), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        progressContainer.addSubview(progressTitleLabel)
        progressContainer.addSubview(progressLabel)
        progressContainer.addSubview(progressView)
        progressContainer.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            progressContainer.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            progressContainer.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            progressContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),

            progressTitleLabel.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: 16),
            progressTitleLabel.topAnchor.constraint(equalTo: progressContainer.topAnchor, constant: 16),
            progressLabel.leadingAnchor.constraint(greaterThanOrEqualTo: progressTitleLabel.trailingAnchor, constant: 8),
            progressLabel.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor, constant: -16),
            progressLabel.centerYAnchor.constraint(equalTo: progressTitleLabel.centerYAnchor),

            progressView.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor, constant: -16),
            progressView.topAnchor.constraint(equalTo: progressTitleLabel.bottomAnchor, constant: 16),

            cancelButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 12),
            cancelButton.centerXAnchor.constraint(equalTo: progressContainer.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: -12)
        ])
    }

    private func updateProgress(_ progress: Float) {
        let value = max(0, min(progress, 1))
        currentProgress = value
        progressView.setProgress(value, animated: true)
        updateProgressLabel()
    }

    private func updateSpeed(_ bytesPerSecond: Int64) {
        currentSpeed = max(0, bytesPerSecond)
        updateProgressLabel()
    }

    private func updateProgressLabel() {
        let percentage = Int((currentProgress * 100.0).rounded())
        let speed = ByteCountFormatter.string(fromByteCount: currentSpeed, countStyle: .file)
        progressLabel.text = "\(percentage)% · \(speed)/s"
    }

    @objc private func cancelDownload() {
        cancelButton.isEnabled = false
        progressTitleLabel.text = "正在取消下载…"
        downloadToken?.cancel()
    }

    private func finishDownload(error: MediaDownloadError?) {
        defer {
            downloadToken = nil
            navigationItem.rightBarButtonItem?.isEnabled = true
        }

        if let error {
            progressTitleLabel.text = error == .cancel ? "下载已取消" : "下载失败"
            progressLabel.text = error.localizedDescription
            cancelButton.isHidden = true
            return
        }

        updateProgress(1)
        progressTitleLabel.text = "下载完成"
        cancelButton.isHidden = true
    }
}
