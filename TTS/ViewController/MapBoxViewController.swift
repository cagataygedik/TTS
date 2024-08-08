//
//  MapBoxViewController.swift
//  TTS
//
//  Created by Celil Çağatay Gedik on 7.08.2024.
//

import UIKit
import NaturalLanguage
import MapboxSpeech
import AVFoundation

// https://github.com/mapbox/mapbox-speech-swift

final class MapBoxViewController: UIViewController {
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
    
    private let mapboxAccessToken = "<Your_MapBox_Token>"
    private var audioPlayer: AVAudioPlayer?
    
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
        
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        guard let languageCode = recognizer.dominantLanguage?.rawValue else {
            print("Can't detect language")
            return
        }
        
        let options = SpeechOptions(text: text)
        options.locale = Locale(identifier: languageCode)
        let speechSynth = SpeechSynthesizer(accessToken: mapboxAccessToken)
        
        speechSynth.audioData(with: options) { (data, error) in
            guard let data = data else {
                print("Error generating speech: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                self.audioPlayer = try AVAudioPlayer(data: data)
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
            } catch {
                print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
            }
        }
    }
    
    private func tapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
}
