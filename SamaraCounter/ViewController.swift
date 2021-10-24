//
//  ViewController.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 20.12.2020.
//

import UIKit

import UIKit
import BxInputController
import CircularSpinner
import Alamofire
import Fuzi
import PromiseKit

class ViewController: BxInputController {
    
    let waterCounterMaxCount = 3
    
    // Go button
    
    let startRow = BxInputIconActionRow<String>(icon: nil, title: "Start")
    
    // Input Fields:
    
    var id: String = ""
    var order: Int = 0
    
    var surnameRow = BxInputTextRow(title: "Фамилия", maxCount: 200, value: "")
    var nameRow = BxInputTextRow(title: "Имя", maxCount: 200, value: "")
    var patronymicRow = BxInputTextRow(title: "Отчества", maxCount: 200, value: "")
    var streetRow = BxInputTextRow(title: "Улица", subtitle: "например: ул. Больничная или пр. Кирова", maxCount: 200, value: "")
    var homeNumberRow = BxInputTextRow(title: "Номер дома", maxCount: 5, value: "")
    var flatNumberRow = BxInputTextRow(title: "Номер квартиры", maxCount: 5, value: "")
    var phoneNumberRow = BxInputFormattedTextRow(title: "Телефон", prefix: "+7", format: "(###)###-##-##")
    var emailRow = BxInputTextRow(title: "E-mail", maxCount: 50, value: "")
    var rksAccountNumberRow = BxInputTextRow(title: "Номер счета РКС", subtitle: "если необходим", maxCount: 20, value: "")
    var esPlusAccountNumberRow = BxInputTextRow(title: "Лицевой счёт Т+", subtitle: "если необходим", maxCount: 20, value: "")
    var commentsRow = BxInputTextMemoRow(title: "Коментарии", maxCount: 1000, value: "")

    var electricAccountNumberRow = BxInputTextRow(title: "Лицевой счет", subtitle: "как правило 8 цифр", maxCount: 20, value: "")
    var electricCounterNumberRow = BxInputTextRow(title: "Номер счётчика", maxCount: 20, value: "")
    var dayElectricCountRow = BxInputTextRow(title: "День", subtitle: "целые числа, без дробных", maxCount: 10, value: "")
    var nightElectricCountRow = BxInputTextRow(title: "Ночь", subtitle: "целые числа, без дробных", maxCount: 10, value: "")
    
    var waterCounters: [WaterCounterViewModel] = []
    
    let servicesRows : [CheckProviderProtocol] = [
        CheckProviderRow(RKSSendDataService()),
        CheckProviderRow(EsPlusSendDataService()),
        CheckProviderRow(SamGESSendDataService())
    ]
    
    let sendFooter: UIView = {
        let foother = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        foother.backgroundColor = .clear
        
        let btSend = UIButton(frame: CGRect(x: 20, y: 10, width: 60, height: 40))
        btSend.layer.cornerRadius = 8
        btSend.backgroundColor = .systemRed
        btSend.setTitleColor(.white, for: .normal)
        btSend.setTitleColor(.yellow, for: .highlighted)
        btSend.setTitle("Отправить показания", for: .normal)
        btSend.addTarget(self, action: #selector(start), for: .touchUpInside)
        
        foother.addSubview(btSend)
        btSend.translatesAutoresizingMaskIntoConstraints = false
        btSend.leadingAnchor.constraint(equalTo: foother.leadingAnchor, constant: 20).isActive = true
        btSend.trailingAnchor.constraint(equalTo: foother.trailingAnchor, constant: -20).isActive = true
        btSend.topAnchor.constraint(equalTo: foother.topAnchor, constant: 10).isActive = true
        btSend.bottomAnchor.constraint(equalTo: foother.bottomAnchor, constant: -30).isActive = true
        btSend.widthAnchor.constraint(equalToConstant: 60).isActive = true
        btSend.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        return foother
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isEstimatedContent = true
        
        homeNumberRow.textSettings.keyboardType = .numberPad
        flatNumberRow.textSettings.keyboardType = .numberPad
        
        electricAccountNumberRow.textSettings.keyboardType = .numberPad
        electricCounterNumberRow.textSettings.keyboardType = .decimalPad
        dayElectricCountRow.textSettings.keyboardType = .numberPad
        nightElectricCountRow.textSettings.keyboardType = .numberPad
        
        esPlusAccountNumberRow.textSettings.keyboardType = .numberPad
        
        updateData()
        
        startRow.isImmediatelyDeselect = true
        startRow.handler = {[weak self] _ in
            self?.start()
        }
        
        URLSessionConfiguration.default.timeoutIntervalForRequest = 60
        
    }
    
    func updateData() {
        
        var flatEntity = FlatEntity()
        
        if let entity = DatabaseManager.shared.commonRealm.objects(FlatEntity.self).first {
            flatEntity = entity
        } else {
            DatabaseManager.shared.commonRealm.beginWrite()
            flatEntity.id = UUID().uuidString
            flatEntity.order = 1
            DatabaseManager.shared.commonRealm.add(flatEntity, update: .all)
            do {
                try DatabaseManager.shared.commonRealm.commitWrite()
            } catch let error {
                DatabaseManager.shared.commonRealm.cancelWrite()
                showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут: \(error)")
            }
        }
        
        id = flatEntity.id
        order = flatEntity.order
        
        surnameRow.value = flatEntity.surname
        nameRow.value = flatEntity.name
        patronymicRow.value = flatEntity.patronymic
        streetRow.value = flatEntity.street
        homeNumberRow.value = flatEntity.homeNumber
        flatNumberRow.value = flatEntity.flatNumber
        phoneNumberRow.value = flatEntity.phoneNumber
        emailRow.value = flatEntity.email
        rksAccountNumberRow.value = flatEntity.rksAccountNumber
        esPlusAccountNumberRow.value = flatEntity.esPlusAccountNumber
        commentsRow.value = flatEntity.comments
        
        electricAccountNumberRow.value = "\(flatEntity.electricAccountNumber)"
        electricCounterNumberRow.value = "\(flatEntity.electricCounterNumber)"
        dayElectricCountRow.value = "\(flatEntity.dayElectricCount)"
        nightElectricCountRow.value = "\(flatEntity.nightElectricCount)"
        
        var sections = [
            BxInputSection(headerText: "Данные собственника",
                           rows: [surnameRow, nameRow, patronymicRow, streetRow, homeNumberRow, flatNumberRow, phoneNumberRow, emailRow, rksAccountNumberRow, esPlusAccountNumberRow],
                           footerText: nil),
            BxInputSection(headerText: "Показания электрического счётчика", rows: [electricAccountNumberRow, electricCounterNumberRow, dayElectricCountRow, nightElectricCountRow], footerText: nil)
        ]
        
        waterCounters = []
        for waterCounterEntity in flatEntity.waterCounters {
            let waterCounter = WaterCounterViewModel(entity: waterCounterEntity)
            
            waterCounters.append(waterCounter)
            sections.append(waterCounter.section)
        }
        
        if waterCounters.count < waterCounterMaxCount {
            let waterCounter = WaterCounterViewModel()
            
            waterCounters.append(waterCounter)
            sections.append(waterCounter.section)
        }
        
        servicesRows.forEach{ row in
            row.updateValue(flatEntity)
        }
        let servicesSection = BxInputSection(headerText: "Куда отправляем", rows: servicesRows, footerText: "Выберите поставщиков комунальных услуг, для которых требуется отправлять показания приборов")
        sections.append(servicesSection)
        
        

        sections.append(BxInputSection(headerText: "Проверьте данные и нажмите:", rows: [], footerText: nil))
        sections.append(BxInputSection(header: BxInputSectionView(sendFooter), rows: []))
        
        self.sections = sections
        for row in servicesRows {
            addChecker(row.createChecker(), for: row)
        }
    }
    
    func saveFlatData(){
        if let flatEntity = DatabaseManager.shared.commonRealm.object(ofType: FlatEntity.self, forPrimaryKey: id)
        {
            DatabaseManager.shared.commonRealm.beginWrite()
            
            flatEntity.sentDate = Date()
            
            flatEntity.surname = surnameRow.value ?? ""
            flatEntity.name = nameRow.value ?? ""
            flatEntity.patronymic = patronymicRow.value ?? ""
            flatEntity.street = streetRow.value ?? ""
            flatEntity.homeNumber = homeNumberRow.value ?? ""
            flatEntity.flatNumber = flatNumberRow.value ?? ""
            flatEntity.phoneNumber = phoneNumberRow.value ?? ""
            flatEntity.email = emailRow.value ?? ""
            flatEntity.rksAccountNumber = rksAccountNumberRow.value ?? ""
            flatEntity.esPlusAccountNumber = esPlusAccountNumberRow.value ?? ""
            flatEntity.comments = commentsRow.value ?? ""
            
            flatEntity.electricAccountNumber = electricAccountNumberRow.value ?? ""
            flatEntity.electricCounterNumber = electricCounterNumberRow.value ?? ""
            #warning("Please check dayElectricCountRow & nightElectricCountRow to Int values")
            flatEntity.dayElectricCount = dayElectricCountRow.value ?? ""
            flatEntity.nightElectricCount = nightElectricCountRow.value ?? ""
            
            flatEntity.serviceProvidersToSending = servicesRows.compactMap{ row -> String? in
                if row.value {
                    return row.serviceName
                }
                return nil
            }.joined(separator: String(FlatEntity.serviceProvidersToSendingDevider))
            
            DatabaseManager.shared.commonRealm.add(flatEntity, update: .modified)
            do {
                try DatabaseManager.shared.commonRealm.commitWrite()
            } catch let error {
                DatabaseManager.shared.commonRealm.cancelWrite()
                showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут: \(error)")
            }
        } else {
            showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут")
        }
    }
    
    func saveData(waterCounter: WaterCounterViewModel){
        if let _ = DatabaseManager.shared.commonRealm.object(ofType: WaterCounterEntity.self, forPrimaryKey: waterCounter.id)
        {
            DatabaseManager.shared.commonRealm.beginWrite()
            let waterCounterEntity = waterCounter.entity
            DatabaseManager.shared.commonRealm.add(waterCounterEntity, update: .modified)
            do {
                try DatabaseManager.shared.commonRealm.commitWrite()
            } catch let error {
                DatabaseManager.shared.commonRealm.cancelWrite()
                showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут: \(error)")
            }
        } else {
            DatabaseManager.shared.commonRealm.beginWrite()
            let waterCounterEntity = waterCounter.entity
            waterCounterEntity.id = UUID().uuidString
            let waterCounterOrder : Int = DatabaseManager.shared.commonRealm.objects(WaterCounterEntity.self).sorted(byKeyPath: "order").last?.order ?? 0
            waterCounterEntity.order = waterCounterOrder + 1
            DatabaseManager.shared.commonRealm.add(waterCounterEntity, update: .all)
            if let flatEntity = DatabaseManager.shared.commonRealm.object(ofType: FlatEntity.self, forPrimaryKey: id)
            {
                flatEntity.waterCounters.append(waterCounterEntity)
            }
            do {
                try DatabaseManager.shared.commonRealm.commitWrite()
                updateData()
            } catch let error {
                DatabaseManager.shared.commonRealm.cancelWrite()
                showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут: \(error)")
            }
        }
    }
    
    func saveData(for row: BxInputValueRow) {
        if let waterCounter = waterCounters.first(where: { (waterCounter) -> Bool in
            return waterCounter.contains(row)
        })
        {
            saveData(waterCounter: waterCounter)
        } else {
            saveFlatData()
        }
    }
    
    override func didChangeValue(for row: BxInputValueRow) {
        super.didChangeValue(for: row)
        saveData(for: row)
    }
    
    @objc
    func start() {
        guard checkAllRows() else {
            showAlert(title: "Ошибка", message: "Проверьте данные...")
            return
        }
        startServices()
    }
    
    func startServices() {

        var services : [Promise<Data>] = []
        servicesRows.forEach{ row in
            row.update(services: &services, input: self)
        }
        when(fulfilled: services)
        .done {[weak self] datas in
            CircularSpinner.hide()
            self?.showAlert(title: "Bingo!", message: "Ваши показания успешно отправлены")
        }.catch {[weak self] error in
            CircularSpinner.hide()
            self?.showAlert(title: "Ошибка", message: error.localizedDescription)
        }
    }
    
    func showAlert(title: String, message: String){
        let okAction = UIAlertAction(title: "OK", style: .default) {[weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    


}



