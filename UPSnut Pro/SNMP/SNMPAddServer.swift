//
//  NUTAddServer.swift
//  UPSnut Pro
//
//  Created by Ioan Moldovan on 30.07.2022.
//
import UIKit
import SwiftUI

class SNMPAddServer: UIHostingController<SNMPAddServerView> {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SNMPAddServerView())
    }
    
    init?(_ snmpVC: SNMPViewController)
    {
        
        super.init( rootView: SNMPAddServerView(vcContext: snmpVC))
    }
}


struct SNMPAddServerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var vcContext: SNMPViewController?
    
    
    @State var serverNickname = ""
    @State var serverHostname = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Details")) {
                    TextField("UPS name", text: $serverNickname).disableAutocorrection(true)  .autocapitalization(.none)
                    
                }
                
                Section(header: Text("Network Details")) {
                    TextField("Hostname", text: $serverHostname).disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    
                }
                
                Button(action: {
                    guard self.serverNickname != "" else {return}
                    guard self.serverHostname != "" else {return}

                   
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    let newServer = SNMPnutDB(context: context)
                    newServer.id = UUID()
                    newServer.nickname = self.serverNickname
                    newServer.hostname = self.serverHostname

                    do {
                        try context.save()
                        self.presentationMode.wrappedValue.dismiss()
                        vcContext?.refreshCommand(self)
                    } catch {
                        print(error.localizedDescription)
                    }
                }) {
                    Text("Add Server")
                }
                .navigationBarTitle("Add Server")
                .navigationBarItems(leading:
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label:
                        {
                            Text("Cancel")
                        }
                    )
                )
            }
        }
    }
}
