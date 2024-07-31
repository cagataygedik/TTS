//
//  ViewController.swift
//  TTS
//
//  Created by Celil Çağatay Gedik on 31.07.2024.
//

import UIKit
import SnapKit
import AVFoundation
import NaturalLanguage

class ViewController: UIViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
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
        
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        guard let languageCode = recognizer.dominantLanguage?.rawValue else {
            print("can't detect language")
            return
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        synthesizer.speak(utterance)
    }
}

