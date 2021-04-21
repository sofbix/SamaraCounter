//
//  SamGESSendDataService.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 23.12.2020.
//

import Foundation
import PromiseKit
import Alamofire

struct SamGESSendDataService : ApiService {
    
    
    typealias Input = ViewController
    
    
    let name: String = "SamGES"
    let title: String = "СамГЭС"
    
    
    func map(_ input: Input) -> Promise<Data> {
        
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8",
        ]
        
        let body = "nls=\(input.electricAccountNumberRow.value ?? "")&devSnumber=\(input.electricCounterNumberRow.value ?? "")&devShow=&devShowD=\(input.dayElectricCountRow.value ?? "")&devShowN=\(input.nightElectricCountRow.value ?? "")&devShowP=&devShowPP=&devShowNN=&f=8"
        

        var request = try! URLRequest(url: "https://service.samges.ru/PrivatePublic/npubserv", method: .post, headers: headers)
        request.httpBody = body.data(using: .utf8)
        
        return service(request)

    }
    
    func checkOutputData(with data: Data) -> String? {
        
        if let stringData = String(data: data, encoding: .utf8)
            
        {
            if stringData == "OK:" {
                return nil
            } else {
                print(stringData)
                return "Что то пошло не так с СамГЭС"
            }
        }
        
        return "Ошибка отправки для СамГЭС. Нет данных."
    }
    
    
}
