//
//  CheckProviderRow.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 21.04.2021.
//

import BxInputController
import PromiseKit

protocol CheckProviderProtocol {
    
    var value: Bool {get}
    
    var serviceName: String {get}
    
    func update(services: inout [Promise<Data>], input: ViewController)
    
    func updateValue(_ entity: FlatEntity)
}

class CheckProviderRow<T: ApiService>: BxInputCheckRow
{

    let service: T
    
    required init(_ service: T){
        self.service = service
        super.init(title: service.title, subtitle: nil, placeholder: nil, value: true)
    }
    
}

extension CheckProviderRow: CheckProviderProtocol where T.Input == ViewController
{
    
    func update(services: inout [Promise<Data>], input: ViewController) {
        if value {
            services.append(ProgressService().start(with: "Передача в " + service.title))
            services.append(service.start(with: input))
        }
    }
    
    var serviceName: String {
        return service.name
    }
    
    func updateValue(_ entity: FlatEntity) {
        let serviceProvidersToSending = entity.serviceProvidersToSending
        guard serviceProvidersToSending.isEmpty == false else {
            value = true
            return
        }
        let services = serviceProvidersToSending.split(separator: FlatEntity.serviceProvidersToSendingDevider)
        value = services.contains(Substring(serviceName))
    }
    
}
