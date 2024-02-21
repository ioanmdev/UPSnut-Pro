//
//  NUTDetailController.swift
//  UPSnut Pro
//
//  Created by Ioan Moldovan on 28.07.2022.
//

import UIKit
import SwiftUI

class NUTDetailController: UIHostingController<NUTDetailView> {
    
    public var selectedUPS: UPSnutDB?
    
    override func viewDidLoad() {
        rootView = NUTDetailView(selectedServer: selectedUPS)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: NUTDetailView(selectedServer: selectedUPS))
    }
    
}

struct NUTDetailView: View {
    
    var selectedServer: UPSnutDB?
    
    @State var showLoading = true
    @State var statusLines: [String : String] = [String : String]()
    
    var beautifulNames: [String : String] = [
        "input.frequency.nominal": "Nominal Input Frequency: ",
        "ups.delay.start": "UPS Start Delay: ",
        "driver.version" : "Driver Version: ",
        "ups.delay.shutdown": "UPS Shutdown Delay: ",
        "driver.version.internal": "Internal Driver Version: ",
        "input.voltage": "Input Voltage: ",
        "input.frequency" : "Input Frequency: ",
        "ups.status" : "UPS Status: ",
        "ups.load" : "UPS Load: ",
        "battery.voltage" : "Battery Voltage: ",
        "battery.charge" : "Battery Charge: ",
        "device.mfr" : "Device Manufacturer: ",
        "device.model": "Device Model: ",
        "battery.type": "Battery Type: "
        
    ]
    
    var body: some View {
        LoadingView (isShowing: $showLoading) {
            VStack (alignment: .leading) {
                Text("Connection Details").font(.title)
                    .padding(.bottom, 20)
                Text("Hostname: " + self.selectedServer!.hostname!)
                    .padding(.bottom, 5)
                Text("Port: " + String(self.selectedServer!.port))
                    .padding(.bottom, 5)
                
                Divider()
                
                Text("Server Status").font(.title).padding(.top, 10)
                List {
                    ForEach(self.statusLines.sorted(by: <), id: \.key)
                    { resultKey, resultValue in
                        if let niceName = beautifulNames[resultKey] {
                            HStack {
                                Text(niceName).bold().frame(alignment: .leading)
                                Text(resultValue).frame(alignment: .trailing)
                            }.padding(10)
                            
                        }
                        
                    }.listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                }
                
            }
            .padding()
            .navigationBarTitle("\(self.selectedServer!.nickname!) Status", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.showLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    self.loadData()
                })
            }, label: {
                 Image(systemName: "arrow.clockwise")
                .resizable()
                    .frame(width: 21, height: 24)
     
            }))
        }.onAppear() {
            self.showLoading = true
            DispatchQueue.main.async {
                self.loadData()
            }
        }
    }
    
    internal func loadData()
    {
        self.statusLines = self.getStatus(hostname: self.selectedServer!.hostname!, port: Int32(self.selectedServer!.port), username: self.selectedServer!.username!, password: self.selectedServer!.password!, nickname: self.selectedServer!.nickname!)
        self.showLoading = false
    }
    
    internal func getStatus(hostname: String, port: Int32, username: String, password: String, nickname: String) -> [String : String]
    {
        let statusQuery = NUTQuery()
        switch statusQuery.GetStatus(hostname, port: port, username: username, password: password, nickname: nickname) {
        case .Success:
            return statusQuery.QueryHashmap
        case .Failure:
            return ["ups.status" : "Status Retrival Failed: Communication Error"]
        }
    }
 
}
