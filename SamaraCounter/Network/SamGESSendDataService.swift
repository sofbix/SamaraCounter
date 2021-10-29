//
//  SamGESSendDataService.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 23.12.2020.
//

import Foundation
import PromiseKit
import Alamofire
import BxInputController

struct SamGESSendDataService : SendDataService {
    
    
    typealias Input = FlatCountersDetailsController
    
    
    let name: String = "SamGES"
    let title: String = "СамГЭС"
    
    func addCheckers(for input: Input){
        let electricAccountNumberChecker = BxInputBlockChecker(row: input.electricAccountNumberRow, subtitle: "Введите непустой номер из чисел", handler: { row in
            let value = input.electricAccountNumberRow.value ?? ""
            
            guard value.count > 0 else {
                return false
            }
            return value.isNumber
        })
        input.addChecker(electricAccountNumberChecker, for: input.electricAccountNumberRow)
        
        input.addChecker(BxInputEmptyValueChecker(row: input.electricCounterNumberRow, placeholder: "Значение должно быть не пустым"), for: input.electricCounterNumberRow)
        
        let dayElectricCountChecker = BxInputBlockChecker(row: input.dayElectricCountRow, subtitle: "Укажите целочисленное значение счетчика", handler: { row in
            let value = input.dayElectricCountRow.value ?? ""
            
            guard value.count > 0 else {
                return false
            }
            return value.isNumber
        })
        input.addChecker(dayElectricCountChecker, for: input.dayElectricCountRow)
        
        let nightElectricCountChecker = BxInputBlockChecker(row: input.nightElectricCountRow, subtitle: "Оставте пустым или целочисленное значение", handler: { row in
            let value = input.nightElectricCountRow.value ?? ""
            
            if value.count == 0 {
                return true
            }
            return value.isNumber
        })
        input.addChecker(nightElectricCountChecker, for: input.nightElectricCountRow)
    }
    
    
    func map(_ input: Input) -> Promise<Data> {
        
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8",
        ]
        
        let dayValue = input.dayElectricCountRow.value ?? ""
        let nightValue = input.nightElectricCountRow.value ?? ""
        let requestString = nightValue.isEmpty
            ? "devShow=\(dayValue)&devShowD=&devShowN="
            : "devShow=&devShowD=\(dayValue)&devShowN=\(nightValue)"
        
        let body = "nls=\(input.electricAccountNumberRow.value ?? "")&devSnumber=\(input.electricCounterNumberRow.value ?? "")&\(requestString)&devShowP=&devShowPP=&devShowNN=&f=8"

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
    
    func firstlyCheckAvailable() -> String? {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        if day < 15 || day > 25 {
            return "Принимает с 15 по 25 число"
        }
        return nil
    }
    
    
}
