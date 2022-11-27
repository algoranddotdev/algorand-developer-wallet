//
//  NetworksView.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/19/22.
//

import SwiftUI

struct NetworksView: View {
  @FetchRequest(sortDescriptors: []) var networks: FetchedResults<AlgorandNetwork>
  
  @Environment(\.managedObjectContext) var managedObjectContext
  
  @State private var isAddSheetVisible = false
  @State private var isEditSheetVisible = false
  
  var body: some View {
    VStack {
      List {
        Section {
          ForEach(networks) { network in
            HStack(spacing: 0) {
              Text(network.name)
                .frame(maxWidth: .infinity, alignment: .leading)
              
              Image(systemName: network.isActive ? "checkmark.square.fill" : "square")
                .font(.system(size: 16))
                .foregroundColor(Colors.Material.teal[500])
            }
              .onTapGesture {
                withAnimation {
                  for network in networks {
                    network.isActive = false
                  }
                  network.isActive = true
                  
                  do {
                    try managedObjectContext.save()
                  } catch {
                    print(error.localizedDescription)
                  }
                }
              }
          }
          .onDelete { indexSet in
            for index in indexSet {
              managedObjectContext.delete(networks[index])
            }
            do {
              try managedObjectContext.save()
            } catch {
              print(error.localizedDescription)
            }
          }
        } header: {
          Text("Networks")
        }
        
        Button {
          isAddSheetVisible.toggle()
        } label: {
          Text("Add Network")
        }
        .sheet(isPresented: $isAddSheetVisible) {
          AddSheet()
        }
      }
    }
  }
}

struct NetworksView_Previews: PreviewProvider {
  static var previews: some View {
    NetworksView()
  }
}

extension NetworksView {
  struct AddSheet: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    
    @State private var networkType: AlgorandNetworkType = .sandbox
    @State private var networkName = ""
    @State private var networkHost = ""
    
    var body: some View {
      Form {
        Section {
          Picker("Type", selection: $networkType) {
            ForEach(AlgorandNetworkType.allCases) { networkType in
              Text(networkType.name)
            }
          }
          
          TextField("Name", text: $networkName)
          
          TextField("Host", text: $networkHost)
        } header: {
          Text("Network")
        }
        Section {
          Button {
            withAnimation {
              let network = AlgorandNetwork(context: managedObjectContext)
              network.type = networkType
              network.name = networkName
              network.host = networkHost
              network.isActive = false
              
              do {
                try managedObjectContext.save()
                print("saved")
                dismiss()
              } catch {
                print(error)
              }
            }
          } label: {
            Text("Add")
          }
        }
      }
    }
  }
}
