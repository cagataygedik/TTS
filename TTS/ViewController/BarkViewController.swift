//
//  BarkViewController.swift
//  TTS
//
//  Created by Celil Çağatay Gedik on 7.08.2024.
//

import UIKit
import AVFAudio
import NaturalLanguage

final class BarkViewController: UIViewController {
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isScrollEnabled = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    private let speakButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔊 Speak", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemIndigo
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var personalVoiceIdentifier: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tapGesture()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGray6
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.height.greaterThanOrEqualTo(50)
        }
        
        speakButton.addTarget(self, action: #selector(speakText), for: .touchUpInside)
        view.addSubview(speakButton)
        speakButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.centerX.equalTo(view)
            make.height.equalTo(50)
            make.width.equalTo(300)
        }
    }
    
    @objc private func speakText() {
        guard let text = textView.text, !text.isEmpty else { return }
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        getAudioFromServer(text: text)
    }
    
    private func getAudioFromServer(text: String) {
        let url = URL(string: "http://127.0.0.1:5001/generate_audio")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60000
        
        let json: [String: Any] = ["text": text]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("error: \(error)")
                return
            }
            guard let data = data else {
                print("no data returned")
                return
            }
            print("data received: \(data.count) bytes")
            self.playAudio(data: data)
        }
        task.resume()
    }
    
    private func playAudio(data: Data) {
        DispatchQueue.main.async {
            do {
                let audioPlayer = try AVAudioPlayer(data: data)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                print("audio is playinh")
            } catch {
                print("error playing audio: \(error.localizedDescription)")
            }
        }
    }
    
    private func tapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
}
