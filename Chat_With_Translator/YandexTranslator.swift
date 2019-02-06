//
//  YandexTranslator.swift
//  Chat_With_Translator
//
//  Created by Admin on 30/01/2019.
//  Copyright © 2019 xelwow98. All rights reserved.
//

import Foundation

class YTUrl {
    static var YandexTranslator = "https://translate.yandex.net/api/v1.5/tr.json"
    static var languageDetection = "/detect"
    static var translation = "/translate"
    static var ApiKey = "trnsl.1.1.20190204T084745Z.e884112d5c442fb3.f0992f7f3250d196508c535bb38bd68bc18d236f"
}

struct TranslationResponse : Codable {
    var code : Int
    var text : [String]
    var lang : String
}

struct LanguageDetected : Codable{
    var code : Int
    var lang : String
}

protocol YandexTranslatorDelegate {
    func getTranslation(origin: String, translation : String)
}

class YandexTranslator {
    
    var delegate : YandexTranslatorDelegate?
    
    private var ApiKey = "trnsl.1.1.20190204T084745Z.e884112d5c442fb3.f0992f7f3250d196508c535bb38bd68bc18d236f"
    
    
    init(){
        
    }
    init(ApiKey: String){
        self.ApiKey = ApiKey
    }
    
    private func getTranslation(text : String, translation language : String){
        
        let urlStr = "\(YTUrl.YandexTranslator)\(YTUrl.translation)?key=\(ApiKey)&text=\(text)&lang=\(language)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlStr!)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse)
            print(data.debugDescription)
            if error != nil {
                print(error)
            }
            else {
                guard let data = data else {return}
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(TranslationResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.delegate?.getTranslation(origin: text, translation: decodedData.text[0])
                    }
                }
                catch{
                    return
                }
            }
        }
        task.resume()
    }
    
    func translate(text: String, hint : String){
        let urlStr = "\(YTUrl.YandexTranslator)\(YTUrl.languageDetection)?key=\(YTUrl.ApiKey)&text=\(text)&hint=\(hint)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlStr!)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse)
            print(data.debugDescription)
            if error != nil {
                print(error)
            }
            else {
                guard let data = data else {return}
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(LanguageDetected.self, from: data)
                    let lang = decodedData.lang == "en" ? decodedData.lang + "-ru" : decodedData.lang + "-en"
                    DispatchQueue.main.async {
                        self.getTranslation(text: text, translation: lang)
                    }
                }
                catch{
                    return
                }
            }
        }
        task.resume()
    }
}
