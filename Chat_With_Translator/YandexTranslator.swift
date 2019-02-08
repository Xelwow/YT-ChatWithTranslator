//
//  YandexTranslator.swift
//  Chat_With_Translator
//
//  Created by Admin on 30/01/2019.
//  Copyright © 2019 xelwow98. All rights reserved.
//

import Foundation

class YTUrl {
    static var languageDetection = "https://translate.yandex.net/api/v1.5/tr.json/detect"
    static var translation = "https://translate.yandex.net/api/v1.5/tr.json/translate"
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
    
    private var ApiKey = ""
    
    
    init(ApiKey: String){
        self.ApiKey = ApiKey
    }
    
    func setApiKey(ApiKey : String){
        self.ApiKey = ApiKey
    }
    
    private func getTranslation(text : String, translation language : String){
        
        let urlStr = "\(YTUrl.translation)?key=\(ApiKey)&text=\(text)&lang=\(language)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
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
                return
            }
            if httpResponse?.statusCode == 200 {
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
            else {
                switch httpResponse?.statusCode {
                case 401 :
                    print("Неправильный API-ключ")
                    break
                case 402 :
                    print("API-ключ заблокирован")
                    break
                case 404 :
                    print("Превышено суточное ограничение на объем переведенного текста")
                    break
                default : break
                }
            }
        }
        task.resume()
    }
    
    func translate(text: String, hint : String){
        let urlStr = "\(YTUrl.languageDetection)?key=\(ApiKey)&text=\(text)&hint=\(hint)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
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
                return
            }
            if httpResponse?.statusCode == 200 {
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
            else {
                switch httpResponse?.statusCode {
                case 401 :
                    print("Неправильный API-ключ")
                    break
                case 402 :
                    print("API-ключ заблокирован")
                    break
                case 404 :
                    print("Превышено суточное ограничение на объем переведенного текста")
                    break
                case 413 :
                    print("Превышен максимально допустимый размер текста")
                    break
                case 422 :
                    print("Текст не может быть переведен")
                    break
                case 501 :
                    print("Заданное направление перевода не поддерживается")
                    break
                default : break
                }
            }
        }
        task.resume()
    }
}
