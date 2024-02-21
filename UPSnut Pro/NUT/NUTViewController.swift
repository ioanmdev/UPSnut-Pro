//
//  NUTViewController.swift
//  UPSnut Pro
//
//  Created by Ioan Moldovan on 26.07.2022.
//

import UIKit

class NUTViewController: UITableViewController {
    
    var Servers = [UPSnutDB]()
    var ServerStatus = [SrvStatus]()
    
    public func refreshCommand(_ sender: Any)
    {
        loadSavedData()
        animateLoading(context: self)
        
        for server in Servers {
            let statusQuery = NUTQuery()
            switch statusQuery.GetStatus(server.hostname!, port: server.port, username: server.username!, password: server.password!, nickname: server.nickname!) {
            case .Success:
                ServerStatus.append(SrvStatus(BatteryCharge: statusQuery.QueryHashmap["battery.charge"]!, Status: statusQuery.QueryHashmap["ups.status"]!))
            case .Failure:
                let errStat = SrvStatus(BatteryCharge: "Unavailable", Status: "Connection Error")
                ServerStatus.append(errStat)
            }
        }
        
        stopLoading(context: self)
        tableView.reloadData()
    }
    
    func loadSavedData()
    {
        ServerStatus = [SrvStatus]()
        Servers = [UPSnutDB]()
        let serverRequest = UPSnutDB.fetchRequest()
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            try Servers = context.fetch(serverRequest)
        } catch  {
        }
    }
    
    public func addCommand(_ sender: Any)
    {
        let serverAdd = NUTAddServer(self)!
        serverAdd.modalPresentationStyle = UIModalPresentationStyle.popover
        serverAdd.popoverPresentationController?.sourceView = self.view
        serverAdd.popoverPresentationController?.sourceRect = CGRect(x:self.view.bounds.width, y:0,width: 0,height: 0)
        present(serverAdd, animated: true, completion: nil)
    }
    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshCommand(self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Servers.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let table_cell =  tableView.dequeueReusableCell(withIdentifier: "upsnutcell")!
        
        for subview in table_cell.contentView.subviews {
            if subview.accessibilityIdentifier == "upsname" {
                (subview as! UILabel).text = Servers[indexPath.row].nickname
            }
            if subview.accessibilityIdentifier == "upsstatus" {
                (subview as! UILabel).text = ServerStatus[indexPath.row].Status
            }
            if subview.accessibilityIdentifier == "upsbatt" {
                (subview as! UILabel).text = ServerStatus[indexPath.row].BatteryCharge
            }
        }
        return table_cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
       
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(Servers[indexPath.row])
            Servers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            do {
        
            try context.save()
            } catch {
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let upsdetail = segue.destination as? NUTDetailController {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                upsdetail.selectedUPS = Servers[indexPath.row]
            }
        }
    }
    

}

