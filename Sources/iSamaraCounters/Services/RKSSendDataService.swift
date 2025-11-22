//
//  RKSSendDataService.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 22.12.2020.
//  Copyright © 2020 Byterix. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import BxInputController

private struct RCSCountNumber {
    let url: String
    let ls: String
    let token: String
    let assemblyId: String

    var counters: [String: String] = [:]

    var body: String {
        var result = "_token=\(token)&assembly_id=\(assemblyId)&branch_id=SCS&ls=\(ls)&captcha_code_noAuth_counters_send=1763811857-9695289-6921a211ecb3f"
        result.append(counters.map{ "&meter%5B\($0.key)%5D%5B0%5D=\($0.value)" }.joined(separator: ""))
        return result
    }
}

public struct RKSSendDataService : SendDataService {

    public init() {}
    
    
    public let name: String = "RKS"
    public let title: String = "РКС"
    public let days = Range<Int>(uncheckedBounds: (lower: 5, upper: 25))

    public func addCheckers(for input: SendDataServiceInput){
        let rksAccountNumberChecker = BxInputBlockChecker(row: input.rksAccountNumberRow, subtitle: "Введите 10 значный номер с нулями в начале", handler: { row in
            let value = input.rksAccountNumberRow.value ?? ""
            
            guard value.count == 10 else {
                return false
            }
            return value.isNumber
        })
        input.addChecker(rksAccountNumberChecker, for: input.rksAccountNumberRow)
    }
    
    public func map(_ input: SendDataServiceInput) -> Promise<Data> {
        
        
        let headers : HTTPHeaders = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Cookie" : "XSRF-TOKEN=eyJpdiI6IlRsNXdXYXQ1ZjRwajNBOUhMZUs0Tmc9PSIsInZhbHVlIjoiRCtsSm1tV3ZlaHhzbVk3THhNV2h2dXdNTjZLUk1ONFFnSlV6Z1lybXNZUG9JRE1WWkJVSFhBcVpIZjZHZmVRSiIsIm1hYyI6Ijc1OTIxYWE3MTA1OWQ5ZDExNmFjMGJjMmY1N2FkYjRiM2RiM2MwZTA5Y2UxOTNkYmM1MWNiOGQ4ODdmNzg2NmEifQ%3D%3D; laravel_session=eyJpdiI6IkNya1RMM0p4dUF0bGQrT05aakp0T0E9PSIsInZhbHVlIjoiN3FaRGV1eWhQU25CXC9DNm1FaVE1T2hiMmxQSmp3N095eWxqQUJEYU5TY2Q0N1JTZHhqQTh4dkdHbm52ZWtXSXM3OWl0dFZcLzc2SFY5QWZWZ0lCSU9hejdqZ1hGR0UxcWtqS3gzTTh6VkdOMitTbHZcL2hNY2l3azR3S0ptekFLK24iLCJtYWMiOiI1ZGE0ZjY3NDQ3ZDRmMGEwMDQzZTQ0NDdkYTRlZmI5MzFmOTlkOWMyMmM4ODRkYTA4MzUyY2FlNmVmOTY3NzdjIn0%3D; _ym_uid=1763728922952602909; _ym_d=1763729102; _ym_isad=2; _ym_visorc=w"
        ]
        
        var counterSerialNumberDictionary: [String: String] = [:]
        for waterCounter in input.waterCounters {
            if waterCounter.isValid
            {
                counterSerialNumberDictionary[waterCounter.coldSerialNumberRow.value ?? ""] = waterCounter.coldCountRow.value ?? ""
                counterSerialNumberDictionary[waterCounter.hotSerialNumberRow.value ?? ""] = waterCounter.hotCountRow.value ?? ""
            }
        }

        guard let rksAccountNumber = input.rksAccountNumberRow.value else {
            return .init(error: NSError(domain: self.title, code: 404, userInfo: [NSLocalizedDescriptionKey: "\(self.title): Необходим 10-значный лицевой счёт"]))
        }

        // cost get token from pattern: <meta name="csrf-token" content="KjvaeabbqOTsPt10UK6DOXTNj8je19NktucYq7Wi">
        let token = "ZnfygqgEs67C0gK5NbcPsqzvqwNrBT4gPZYXBBOH"

        let body = "_token=\(token)&branch_id=SCS&ls=\(rksAccountNumber)"
        var getRequest = try! URLRequest(url: "https://lk.roscomsys.ru/noAuth/counters/", method: .post, headers: headers)
        getRequest.httpBody = body.data(using: .utf8)

        return service(getRequest, isNeedCheckOutput: false).then{ getData -> Promise<Data> in

            guard let httpString = String(data: getData, encoding: .utf8) else {
                return .init(error: NSError(domain: self.title, code: 404, userInfo: [NSLocalizedDescriptionKey: "\(self.title): Невозможно получить счётчики"]))
            }
            let range = NSRange(location: 0, length: httpString.count)

            let searchFormRegex = try? NSRegularExpression(pattern: #"<form method="post" action="(.*?)"([\s\S]*?)name="_token" value="(.*?)"([\s\S]*?)name="assembly_id" value="(.*?)"([\s\S]*?)<\/form>"#, options: [])

            let searchCounterRegex = try? NSRegularExpression(pattern: #"(?<=(<span>Счетчик №))(.*?)(?=(<\/span>))([\s\S]*?)(?<=(name="meter\[))(.*?)(?=(\]))"#, options: [])

            var countNumbers: [RCSCountNumber] = []

            if let searchFormRegex, let searchCounterRegex {
                let results = searchFormRegex.matches(in: httpString, range: range)
                results.forEach { (result: NSTextCheckingResult) in
                    if result.numberOfRanges == 7 {
                        let postUrl = (httpString as NSString).substring(with: result.range(at: 1))
                        let token = (httpString as NSString).substring(with: result.range(at: 3))
                        let assemblyId = (httpString as NSString).substring(with: result.range(at: 5))
                        let formRange = result.range(at: 6)

                        var countNumber = RCSCountNumber(url: postUrl, ls: rksAccountNumber, token: token, assemblyId: assemblyId)

                        let results = searchCounterRegex.matches(in: httpString, range: formRange)
                        results.forEach { (result: NSTextCheckingResult) in
                            if result.numberOfRanges == 8 {
                                let serialNumber = (httpString as NSString).substring(with: result.range(at: 2))
                                let id = (httpString as NSString).substring(with: result.range(at: 6))

                                if let counterValue = counterSerialNumberDictionary[serialNumber] {
                                    countNumber.counters[id] = counterValue
                                }
                            }
                        }
                        countNumbers.append(countNumber)
                    }
                }
            }
            print("\(countNumbers)")

            let promises = countNumbers.map { countNumber in
                var postHeaders = headers
                postHeaders["branch_id"] = "SCS"
                postHeaders["ls"] = rksAccountNumber
                var postRequest = try! URLRequest(url: countNumber.url, method: .post, headers: postHeaders)
                postRequest.httpBody = countNumber.body.data(using: .utf8)
                return service(postRequest)
            }

            return when(resolved: promises).then{ (datas: [Result<Data>]) -> Promise<Data> in
                for data in datas {
                    switch data {
                    case .fulfilled(let data):
                        if let errorMessage = checkOutputData(with: data) {
                            return .init(error: NSError(domain: self.title, code: 404, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                        }
                    case .rejected(let error):
                        return .init(error: error)
                    }
                }
                return .value(Data())
            }
        }

    }
    
    public func checkOutputData(with data: Data) -> String? {
        
        if let stringData = String(data: data, encoding: .utf8)
            
        {
            if stringData.contains("Для продолжения необходимо решить капчу") {
                return "Требует ввести капчу"
            }
            if stringData.contains("Показания приборов учета приняты") {
                return nil
            } else {
                print(stringData)
                return "Что то пошло не так с РКС"
            }
        }
        
        return "Ошибка отправки для РКС. Нет данных."
    }
    
    
}
