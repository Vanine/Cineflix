//
//  TrailerPlayerView.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 02.03.2026.
//

import SwiftUI
import WebKit

struct TrailerPlayerView: View {
    let youtubeKey: String
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading: Bool = true
    @State private var didFail: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            YouTubePlayerWebView(
                videoKey: youtubeKey,
                isLoading: $isLoading,
                didFail: $didFail
            )
            .ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.4)
            }

            if didFail {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(DesignSystem.Color.accent)
                    Text("Couldn't load trailer")
                        .font(DesignSystem.Typography.title)
                        .foregroundStyle(.white)
                }
            }
        }
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.black.opacity(0.55), in: .circle)
            }
            .padding(.top, DesignSystem.Spacing.md)
            .padding(.leading, DesignSystem.Spacing.md)
        }
    }
}

private struct YouTubePlayerWebView: UIViewRepresentable {
    let videoKey: String
    @Binding var isLoading: Bool
    @Binding var didFail: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
            body { margin: 0; padding: 0; background-color: #000; }
            .container { position: relative; width: 100%; height: 100vh; overflow: hidden; }
            iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }
        </style>
        </head>
        <body>
        <div class="container">
        <iframe src="https://www.youtube.com/embed/\(videoKey)?playsinline=1&autoplay=1&rel=0&modestbranding=1" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
        </div>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let parent: YouTubePlayerWebView

        init(_ parent: YouTubePlayerWebView) {
            self.parent = parent
        }

        nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in
                self.parent.isLoading = false
            }
        }

        nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                self.parent.isLoading = false
                self.parent.didFail = true
            }
        }

        nonisolated func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                self.parent.isLoading = false
                self.parent.didFail = true
            }
        }
    }
}
