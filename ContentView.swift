import SwiftUI
import WebKit
import AVKit

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var iptvUrl = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8" // Test akışı
    
    // Tarayıcı ve YouTube Durumları
    @State private var currentUrlString = "https://m.youtube.com"
    @State private var inputUrl = "https://m.youtube.com"
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 8) {
                // Üst Başlık ve Mod Geçişi
                HStack {
                    Text("CarVievo")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Picker("Mod", selection: $selectedTab) {
                        Text("YouTube / Web").tag(0)
                        Text("IPTV").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if selectedTab == 0 {
                    // --- 1. TARAYICI & YOUTUBE BÖLÜMÜ ---
                    VStack(spacing: 6) {
                        // Hızlı Kısayollar
                        HStack(spacing: 10) {
                            Button(action: { loadUrl("https://m.youtube.com") }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "play.rectangle.fill")
                                    Text("YouTube")
                                }
                                .font(.footnote.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .cornerRadius(8)
                            }
                            
                            Button(action: { loadUrl("https://www.google.com") }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "magnifyingglass")
                                    Text("Google")
                                }
                                .font(.footnote.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // URL ve Arama Çubuğu
                        HStack(spacing: 8) {
                            TextField("URL veya arama terimi girin...", text: $inputUrl, onCommit: {
                                handleUrlSubmit()
                            })
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(8)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            
                            Button(action: { handleUrlSubmit() }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.cyan)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Tam Ekran Tarayıcı Motoru
                        BrowserWebView(urlString: currentUrlString)
                            .cornerRadius(10)
                            .padding(.horizontal, 4)
                    }
                } else {
                    // --- 2. CANLI IPTV BÖLÜMÜ ---
                    VStack(spacing: 8) {
                        HStack {
                            TextField("M3U / Canlı Akış URL...", text: $iptvUrl)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(8)
                                .background(Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        IPTVPlayerView(urlString: iptvUrl)
                            .cornerRadius(10)
                            .padding(.horizontal, 4)
                    }
                }
            }
        }
    }
    
    private func loadUrl(_ target: String) {
        inputUrl = target
        currentUrlString = target
    }
    
    private func handleUrlSubmit() {
        var query = inputUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.lowercased().hasPrefix("http://") && !query.lowercased().hasPrefix("https://") {
            if query.contains(".") && !query.contains(" ") {
                query = "https://" + query
            } else {
                let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
                query = "https://www.google.com/search?q=\(encoded)"
            }
        }
        currentUrlString = query
        inputUrl = query
    }
}

// Araç Ekranına Yansıtılacak Katman (CarPlay / Monitör)
struct ExternalPlayerView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            BrowserWebView(urlString: "https://m.youtube.com")
        }
    }
}

// Web ve Video Destekli WebKit Motoru
struct BrowserWebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let current = uiView.url?.absoluteString, current == urlString {
            return
        }
        if let url = URL(string: urlString) {
            uiView.load(URLRequest(url: url))
        }
    }
}

// Canlı IPTV Oynatıcı
struct IPTVPlayerView: View {
    let urlString: String
    
    var body: some View {
        if let url = URL(string: urlString) {
            VideoPlayer(player: AVPlayer(url: url))
        } else {
            Text("Geçersiz Akış Adresi").foregroundColor(.white)
        }
    }
}
