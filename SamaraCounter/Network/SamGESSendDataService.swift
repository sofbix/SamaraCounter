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
        
        let account = input.electricAccountNumberRow.value ?? ""
        
        
        
        let dayValue = input.dayElectricCountRow.value ?? ""
        let nightValue = input.nightElectricCountRow.value ?? ""
        
        
        let requestString = nightValue.isEmpty
            ? requestParams(index: 0, value: dayValue)
            : requestParams(index: 0, value: dayValue) + requestParams(index: 1, value: nightValue)
        
        let body = "_token=MgxTvzyQoFu8ZkXszqvUtrDdd6WiEYfVWLssbiWR&ls=\(account)\(requestString)"
        
        guard let bodyData = body.data(using: .utf8) else {
            return .init(error: NSError(domain: self.title, code: 404, userInfo: [NSLocalizedDescriptionKey: "\(self.title): Неверный запрос на сервер"]))
        }
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8",
            "Content-Length" : "\(bodyData.count)",
            "Host" : "lk.samges.ru",
            "Cookie" : "_ym_uid=1635105962372771396; _ym_d=1668535546; _ym_isad=2; _fbp=fb.1.1668535546179.1155967397; _ga=GA1.2.1704088370.1668535550; _gid=GA1.2.1685251127.1668535550; XSRF-TOKEN=eyJpdiI6ImFTQzVaTkRDNG9QR1RzWERBeTJDSmc9PSIsInZhbHVlIjoiVVhaa1ZleHo3YWJEaGlkY2FHRWNjRXZDTzRVQ2hNQ3Q3MjJsOVhOTVVhd2R5ZUVGNmlhVnY1bHE1cVUrOHBuNSIsIm1hYyI6IjViMDI0Y2JkNDMyMzY0YTQyYzRhZTFiMThjNjE1ZGYwNTliZDgwNjE2N2YwMDViYjQzMWJjNTQ4NTFhZmY1OTMifQ%3D%3D; laravel_session=eyJpdiI6InlRcUxBYzRuU3BWRkRlWmZBUUc1cUE9PSIsInZhbHVlIjoidWFsQ200TnY1T2s4SFlhU3ZkaTlFOWxsVGtLa2lXVUZFZXFQM2VKanNYalRodVluUlN6SFwvbVRHeGg5Ymg4N2ttZ1hBWHpBdXdVb2Ftam5wbG5iQ2FiWWRlckJYNEtsS0o5Sk12d2ZqaWo2WmFyZVoyUFFyeGNIRVpNdmxYYkl5IiwibWFjIjoiM2U1MzE0NGI3YjE3YmEyYzcxYmVkYWU4MjEyODQxN2Q1NGI0Zjc4ZTgwOWIwZmUwYmFkMjQ4YTA1OTQ4ZWVmNiJ9; _ym_visorc=w"
        ]

        var request = try! URLRequest(url: "https://lk.samges.ru/counters/\(account)", method: .post, headers: headers)
        request.httpBody = bodyData
        
        return service(request)

    }
    
    func checkOutputData(with data: Data) -> String? {
        
        if let stringData = String(data: data, encoding: .utf8)
            
        {
            if stringData == "Показание успешно передано по счетчику" {
                return nil
            } else {
                print(stringData)
                return "Что то пошло не так с СамГЭС"
            }
        }
        
        return "Ошибка отправки для СамГЭС. Нет данных."
    }
    
}
