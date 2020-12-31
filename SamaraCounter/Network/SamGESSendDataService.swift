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
    
    
    let title: String = "СамГЭС"
    
    
    func map(_ input: ViewController) -> Promise<Data> {
        
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Cookie" : "JSESSIONID=01DEA10C4D8CDA49E88B91F976E12A45; _ym_uid=1569932691204228573; _ym_d=1608748340; _ym_isad=1; _ym_visorc_51156908=w; _ym_visorc=w"
        ]
        // проблема в куках: их надо доставать и брать откуда то из логина, пока не понятно как! Но есть обходной путь:
        // https://service.samges.ru/PrivatePublic/Indications.jsp
        // или надо отправлять через email:
        // pokaz@samges.ru
        // \(input.electricAccountNumberRow.value ?? "") 010556148452054 \(input.dayElectricCountRow.value ?? "") \(input.nightElectricCountRow.value ?? "")
        
        let body = "nls=\(input.electricAccountNumberRow.value ?? "")&show1=\(input.dayElectricCountRow.value ?? "")&show2=\(input.nightElectricCountRow.value ?? "")"
        

        var request = try! URLRequest(url: "https://service.samges.ru/Private/AbonServ?__nocache=0.7957026630146569&f=10", method: .post, headers: headers)
        request.httpBody = body.data(using: .utf8)
        
        return service(request)

    }
    
    func checkOutputData(with data: Data) -> String? {
        
        if let stringData = String(data: data, encoding: .utf8)
            
        {
            if stringData == "OK" {
                return nil
            } else {
                print(stringData)
                return "Что то пошло не так с СамГЭС"
            }
        }
        
        return "Ошибка отправки для СамГЭС. Нет данных."
    }
    
    
}
