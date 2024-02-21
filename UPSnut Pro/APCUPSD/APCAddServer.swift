//
//  APCAddServer.swift
//  UPSnut Pro
//
//  Created by Ioan Moldovan on 29.07.2022.
//
import UIKit
import SwiftUI

class APCAddServer: UIHostingController<APCAddServerView> {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: APCAddServerView())
    }
    
    init?(_ apcVC: APCViewController)
    {
        
        super.init( rootView: APCAddServerView(vcContext: apcVC))
    }
}


struct APCAddServerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var vcContext: APCViewController?
    
    @State var serverNickname = ""
    @State var serverHostname = ""
    @State var serverPort = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Details")) {
                    TextField("Nickname", text: $serverNickname).disableAutocorrection(true)
                    
                }
                
                Section(header: Text("Network Details")) {
                    TextField("Hostname", text: $serverHostname).disableAutocorrection(true)
                        .autocapitalization(.none)
                    TextField("Port", text: $serverPort).keyboardType(.numberPad).disableAutocorrection(true)
                    
                    
                }
                
                Button(action: {
                    guard self.serverNickname != "" else {return}
                    guard self.serverHostname != "" else {return}
                    guard self.serverPort != "" else {return}
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    let newServer = NETNISServer(context: context)
                    newServer.id = UUID()
                    newServer.nickname = self.serverNickname
                    newServer.hostname = self.serverHostname
                    newServer.port = Int32(self.serverPort) ?? 0
                    do {
                        try context.save()
                        vcContext?.refreshCommand(self)
                        self.presentationMode.wrappedValue.dismiss()
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
