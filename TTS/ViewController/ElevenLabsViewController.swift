//
//  ElevenLabsViewController.swift
//  TTS
//
//  Created by Celil Çağatay Gedik on 8.08.2024.
//

import UIKit
import Alamofire
import AVFAudio

// https://elevenlabs.io

final class ElevenLabsViewController: UIViewController {
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
    
    private var audioPlayer: AVAudioPlayer?
    private let elevenLabsAPIKey = "<YOUR_API_KEY>"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
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
        
        let parameters: [String: Any] = [
            "text": text,
            "voice_settings": [
                "stability": 0.5,
                "similarity_boost": 0.5
            ]
        ]
        
        let headers: HTTPHeaders = [
            "xi-api-key": elevenLabsAPIKey,
            "Content-Type": "application/json"
        ]
        
        let voiceId = "JBFqnCBsd6RMkjVDRZzb"
        let url = "https://api.elevenlabs.io/v1/text-to-speech/\(voiceId)"
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData { response in
            if let statusCode = response.response?.statusCode, statusCode != 200 {
                print("Error: Received status code \(statusCode)")
                if let json = try? JSONSerialization.jsonObject(with: response.data ?? Data(), options: []) as? [String: Any] {
                    print("Response JSON: \(json)")
                }
                return
            }
            
            switch response.result {
            case .success(let data):
                self.playAudio(data: data)
            case .failure(let error):
                print("Error generating speech: \(error.localizedDescription)")
            }
        }
    }
    
    private func playAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
        }
    }
    
    private func tapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
}
