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
    let days = Range<Int>(uncheckedBounds: (lower: 15, upper: 25))
    
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
    
    func requestParams(index: Int, value: String) -> String {
        return "&counters%5B87278_\(index)%5D%5Bvalue%5D=\(value)&counters%5B87278_\(index)%5D%5BrowId%5D=87278&counters%5B87278_\(index)%5D%5Btarif%5D=\(index)"
    }
    
    func map(_ input: Input) -> Promise<Data> {
        
        var account = input.electricAccountNumberRow.value ?? ""
        if account.first == "0" {
            account.removeFirst()
        }
        
        let getHeaders = [
            "Host" : "lk.samges.ru"
        ]
        
        let getRequest = try! URLRequest(url: "https://lk.samges.ru/counters/\(account)", method: .get, headers: getHeaders)
        
        return service(getRequest, isNeedCheckOutput: false).then{ getData -> Promise<Data> in
            
            guard let httpString = String(data: getData, encoding: .utf8) else {
                return .init(error: NSError(domain: self.title, code: 404, userInfo: [NSLocalizedDescriptionKey: "\(self.title): Невозможно найти токен"]))
            }
            
            let searchTokenRegex = try? NSRegularExpression(pattern: #"(?<=(<input type="hidden" name="_token" value="))(.*?)(?=(">))"#, options: [])
            
            let range = NSRange(location: 0, length: httpString.count)
            guard let tokenResult = searchTokenRegex?.firstMatch(in: httpString, options: [], range: range) else {
                return .init(error: NSError(domain: self.title, code: 404, userInfo: [NSLocalizedDescriptionKey: "\(self.title): Не найден токен"]))
            }
            
            let token = (httpString as NSString).substring(with: tokenResult.range)
            
            let dayValue = input.dayElectricCountRow.value ?? ""
            let nightValue = input.nightElectricCountRow.value ?? ""
            
            
            let requestString = nightValue.isEmpty
                ? requestParams(index: 0, value: dayValue)
                : requestParams(index: 0, value: dayValue) + requestParams(index: 1, value: nightValue)

            let body = "_token=\(token)&ls=\(account)\(requestString)"
            
            guard let bodyData = body.data(using: .utf8) else {
                return .init(error: NSError(domain: self.title, code: 404, userInfo: [NSLocalizedDescriptionKey: "\(self.title): Неверный запрос на сервер"]))
            }
            
            let headers = [
                "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8",
                "Content-Length" : "\(bodyData.count)",
                "Host" : "lk.samges.ru"
            ]

            var request = try! URLRequest(url: "https://lk.samges.ru/counters/\(account)", method: .post, headers: headers)
            request.httpBody = bodyData
            
            return service(request)
        }
    }
    
    func checkOutputData(with data: Data) -> String? {
        
        if let stringData = String(data: data, encoding: .utf8)
            
        {
            if stringData.contains("Показание успешно передано по счетчику") {
                return nil
            } else if stringData.contains("недоступно 1 день") {
                return "\(self.title): Показания уже были переданы, следующий прием через день"
            } else{
                print(stringData)
                return "Что то пошло не так с СамГЭС"
            }
        }
        
        return "Ошибка отправки для СамГЭС. Нет данных."
    }
    
}
