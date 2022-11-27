//
//  ContentView.swift
//  Kenimo
//
//  Created by Morgan Wilde on 9/8/22.
//

import SwiftUI

enum Screens {
  case accounts
  case accountsAddUsingMnemonic
  case networks
}

class KenimoStore: ObservableObject {
//  @AppStorage("Kenimo.Algorand.network") var selectedNetwork = Network.sandbox.rawValue
//  @AppStorage("Kenimo.Algorand.network.host") var sandboxHost = "http://192.168.1.212:4001"
  
  @Published var screen: Screens = .accountsAddUsingMnemonic
  @Published var accounts: [Account] = [
    try! Account(privateKeyBytes: [46, 28, 200, 166, 110, 7, 76, 82, 124, 213, 150, 148, 174, 65, 16, 243, 214, 78, 205, 223, 43, 161, 154, 167, 128, 56, 244, 73, 42, 151, 211, 12]),
    try! Account(privateKeyBytes: [107, 29, 63, 0, 201, 10, 78, 196, 156, 72, 141, 228, 67, 209, 247, 83, 62, 111, 68, 2, 5, 173, 115, 46, 95, 113, 230, 77, 255, 82, 1, 25])
  ]
}

struct MainView: View {
  @StateObject var store = KenimoStore()
  
  var body: some View {
    HierarchyView()
      .environmentObject(store)
  }
}

struct HierarchyView: View {
  @EnvironmentObject var store: KenimoStore
  
  var body: some View {
    ZStack {
      Colors.Material.blueGrey[100]
        .ignoresSafeArea()
      switch store.screen {
      case .accounts:
        AccountsView()
      case .accountsAddUsingMnemonic:
        MnemonicScreen()
      case .networks:
        NetworksView()
      }
    }
    
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
