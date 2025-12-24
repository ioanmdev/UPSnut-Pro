//
//  NUTDetailController.swift
//  UPSnut Pro
//
//  Created by Ioan Moldovan on 28.07.2022.
//

import UIKit
import SwiftUI
import SwiftSnmpKit

class SNMPDetailController: UIHostingController<SNMPDetailView> {
    
    public var selectedUPS: SNMPnutDB?
    
    override func viewDidLoad() {
        rootView = SNMPDetailView(selectedServer: selectedUPS)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SNMPDetailView(selectedServer: selectedUPS))
    }
    
}

struct SNMPDetailView: View {
    
    var selectedServer: SNMPnutDB?
    
    @State var showLoading = true
    @State var statusLines: [String : String] = [String : String]()
    

    
    var body: some View {
        LoadingView (isShowing: $showLoading) {
            VStack (alignment: .leading) {
                Text("Connection Details").font(.title)
                    .padding(.bottom, 20)
                Text("Hostname: " + self.selectedServer!.hostname!)
                    .padding(.bottom, 5)

                
                Divider()
                
                Text("Server Status").font(.title).padding(.top, 10)
                List {
                    ForEach(self.statusLines.sorted(by: <), id: \.key)
                    { resultKey, resultValue in
                        
                            HStack {
                                Text(resultKey).bold().frame(alignment: .leading)
                                Text(resultValue).frame(alignment: .trailing)
                            }.padding(10)
                            
                        
                        
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
    
        self.statusLines =   self.getStatus(self.selectedServer!.hostname!)
        self.showLoading = false
        
    }
    
    internal func getStatus(_ hostname: String)  -> [String : String]
    {
        let statusQuery = SNMPQuery()
        switch  statusQuery.GetStatus(hostname) {
        case .Success:
            return statusQuery.QueryHashmap
        case .Failure:
            return ["Error" : "Status Retrival Failed: Communication Error"]
        }
    }
 
}
