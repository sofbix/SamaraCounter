//
//  HistoryTableController.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 25.10.2021.
//

import Foundation
import UIKit
import RealmSwift

class HistoryTableController: UITableViewController
{
    let newHeader: UIView = UIButton.createOnView(title: "Новые показания", target: self, action: #selector(new))
    let newSegue = "new"
    
    private var entities = DatabaseManager.shared.commonRealm.objects(FlatEntity.self).filter("sentDate != nil").sorted(by: \.sentDate, ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableHeaderView = newHeader

        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < entities.count else {
            return UITableViewCell()
        }
        let entity = entities[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        if let sentDate = entity.sentDate {
            cell.textLabel?.text = DateFormatter.shortDateTimeFormatter.string(from: sentDate)
        } else {
            cell.textLabel?.text = "???"
        }
        return cell
    }
    
    @objc func new() {
        self.performSegue(withIdentifier: newSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == newSegue {
            
        }
    }
    
}
