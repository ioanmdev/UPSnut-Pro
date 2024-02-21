//
//  NUTAddServer.swift
//  UPSnut Pro
//
//  Created by Ioan Moldovan on 30.07.2022.
//
import UIKit
import SwiftUI

class NUTAddServer: UIHostingController<NUTAddServerView> {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: NUTAddServerView())
    }
    
    init?(_ nutVC: NUTViewController)
    {
        
        super.init( rootView: NUTAddServerView(vcContext: nutVC))
    }
}


struct NUTAddServerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var vcContext: NUTViewController?
    
    
    @State var serverNickname = ""
    @State var serverHostname = ""
    @State var serverPort = ""
    @State var serverUsername = ""
    @State var serverPassword = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Details")) {
                    TextField("UPS name", text: $serverNickname).disableAutocorrection(true)  .autocapitalization(.none)
                    
                }
                
                Section(header: Text("Network Details")) {
                    TextField("Hostname", text: $serverHostname).disableAutocorrection(true)
                        .autocapitalization(.none)
                    TextField("Port", text: $serverPort).keyboardType(.numberPad).disableAutocorrection(true)
                    TextField("Username", text: $serverUsername).disableAutocorrection(true)
                        .autocapitalization(.none)
                    TextField("Password", text: $serverPassword).disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    
                }
                
                Button(action: {
                    guard self.serverNickname != "" else {return}
                    guard self.serverHostname != "" else {return}
                    guard self.serverPort != "" else {return}
                    guard self.serverUsername != "" else {return}
                    guard self.serverPassword != "" else {return}
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    let newServer = UPSnutDB(context: context)
                    newServer.id = UUID()
                    newServer.nickname = self.serverNickname
                    newServer.hostname = self.serverHostname
                    newServer.port = Int32(self.serverPort) ?? 0
                    newServer.username = self.serverUsername
                    newServer.password = self.serverPassword
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
