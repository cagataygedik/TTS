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

//Personal voice identifier = com.apple.speech.personalvoice.E4C90227-638B-4EC5-BA35-239CA340DCBC

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
    private var personalVoiceIdentifier: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestPersonalVoiceAuthorization()
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
    
    private func requestPersonalVoiceAuthorization() {
        AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in
            if status == .authorized {
                self.findPersonalVoice()
            } else {
                print("access denied")
            }
        }
    }
    
    private func findPersonalVoice() {
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits == .isPersonalVoice }
        if let personalVoice = voices.first {
            self.personalVoiceIdentifier = personalVoice.identifier
        } else {
            print("No Personal Voice found.")
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
        
        if languageCode == "en", let personalVoiceIdentifier = personalVoiceIdentifier,
            let personalVoice = AVSpeechSynthesisVoice(identifier: personalVoiceIdentifier) {
            utterance.voice = personalVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        }
        synthesizer.speak(utterance)
    }
    
    private func tapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
}
