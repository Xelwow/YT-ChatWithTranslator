//
//  VoiceRecognizer.swift
//  Chat_With_Translator
//
//  Created by Admin on 30/01/2019.
//  Copyright © 2019 xelwow98. All rights reserved.
//

import Foundation
import Speech



protocol CWTSpeechRecognizerDelegate {
    func getRecognizedText(recognized string : String)
}

class CWTSpeechRecognizer : SFSpeechRecognizer {
    let audioEngine = AVAudioEngine()
    var speechRecognizer : SFSpeechRecognizer?
    var request : SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask : SFSpeechRecognitionTask?
    var CWTDelegate : CWTSpeechRecognizerDelegate?
    
    func startRecognition(localiztion : String){
        SFSpeechRecognizer.requestAuthorization { (status) in
            switch status{
            case .authorized:
                AVAudioSession.sharedInstance().requestRecordPermission({ (isGranted) in
                    if isGranted {
                        self.startRecording(localizaion: localiztion)
                    }
                    else{
                        print("User has denied record permission")
                    }
                })
                break
            case .denied:
                print("User has denied SpeechRecognition")
                break
            default:
                break
            }
        }
    }
    
    func stopRecognition(){
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        self.request = nil
        self.recognitionTask = nil
    }
    
    private func startRecording(localizaion : String){
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            request = SFSpeechAudioBufferRecognitionRequest()
            let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.request?.append(buffer)
            }
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localizaion))
            recognitionTask = speechRecognizer!.recognitionTask(with: request!, resultHandler: { (result, error) in
                if error != nil{
                    self.audioEngine.stop()
                    self.audioEngine.inputNode.removeTap(onBus: 0)
                    self.request = nil
                    self.recognitionTask = nil
                }
                else{
                    let resultStr = result?.bestTranscription.formattedString
                    if resultStr != ""{
                        self.CWTDelegate?.getRecognizedText(recognized : resultStr!)
                    }
                }
            })
            audioEngine.prepare()
            try audioEngine.start()
        }
        catch{
            print("Speech recognition has failed")
        }
    }
}
