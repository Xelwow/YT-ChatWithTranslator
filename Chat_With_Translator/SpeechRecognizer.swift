//
//  VoiceRecognizer.swift
//  Chat_With_Translator
//
//  Created by Admin on 30/01/2019.
//  Copyright © 2019 xelwow98. All rights reserved.
//

import Foundation
import Speech

class SpeechRecognizer : SFSpeechRecognizer {
    let audioEngine = AVAudioEngine()
    var speechRecognizer : SFSpeechRecognizer?
    var request : SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask : SFSpeechRecognitionTask?
    
    func recognizeVoice(locale : String){
        SFSpeechRecognizer.requestAuthorization { (status) in
            switch status{
            case .authorized:
                break
            case .denied:
                break
            default:
                break
            }
        }
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: locale))
        
    }
    func startRecording(){
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = audioEngine.inputNode
            request = SFSpeechAudioBufferRecognitionRequest()
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.request?.append(buffer)
            }
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: ""))
            recognitionTask = speechRecognizer!.recognitionTask(with: request!, resultHandler: { (result, error) in
                if error != nil{
                    
                }
                else{
                    let resultStr = result?.bestTranscription.formattedString
                }
            })
        }
        catch{
            
        }
    }
}
