//
//  APCDetailController.swift
//  UPSnut Pro
//
//  Created by Ioan Moldovan on 28.07.2022.
//

import UIKit
import SwiftUI

class APCDetailController: UIHostingController<APCDetailView> {
    
    public var selectedUPS: NETNISServer?
    
    override func viewDidLoad() {
        rootView = APCDetailView(selectedServer: selectedUPS)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: APCDetailView(selectedServer: selectedUPS))
    }
}

struct APCDetailView: View {
    
    var selectedServer: NETNISServer?
    
    @State var showLoading = true
    @State var statusLines: [String] = [String]()
    @State var eventsLines: [String] = [String]()
    
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
                    ForEach(self.statusLines, id: \.self)
                    { resultLine in
                        Text(String(resultLine)).padding(10)
                    }.listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                }
                
                Text("Server Events").font(.title).padding(.top, 10)
                List {
                    ForEach(self.eventsLines, id: \.self)
                    { resultLine in
                        Text(String(resultLine)).padding(10)
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
        self.statusLines = self.getStatus(hostname: self.selectedServer!.hostname!, port: Int32(self.selectedServer!.port))
        self.eventsLines = self.getEvents(hostname: self.selectedServer!.hostname!, port: Int32(self.selectedServer!.port))
        self.showLoading = false
    }
    
    internal func getStatus(hostname: String, port: Int32) -> [String]
    {
        let statusQuery = NISQuery(.Status)
        switch statusQuery.Execute(hostname, port: port) {
        case .Success:
            return statusQuery.QueryResult
        case .Failure:
            return ["Status Retrival Failed: Communication Error"]
        }
    }
    
    internal func getEvents(hostname: String, port: Int32) -> [String]
    {
        let eventsQuery = NISQuery(.Events)
        switch eventsQuery.Execute(hostname, port: port) {
        case .Success:
            return eventsQuery.QueryResult
        case .Failure:
            return ["Events Retrival Failed: Communication Error"]
        }
    }
}

