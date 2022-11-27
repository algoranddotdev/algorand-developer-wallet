//
//  AccountsView.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/17/22.
//

import SwiftUI

struct AccountsView: View {
  @EnvironmentObject var store: KenimoStore
  
  var body: some View {
    Screen { screen in
      if store.accounts.count == 0 {
        Text("Please add an account to get started.")
          .font(.system(size: 14))
          .foregroundColor(Colors.Material.grey[700])
          .padding(16)
      } else {
        VStack(spacing: 8) {
          ForEach(store.accounts) { account in
            Action(title: HStack {
              Text(account.address)
            }) {
//              print(store.sandboxHost)
              Task.init {
                do {
                  let network = Network(variant: .sandbox, host: "http://192.168.86.250:4001")
                  let node = Node(network: network)
                  let transaction = Transaction()
                    .component(try await Transaction.Base.makeInitialized(for: node))
                    .component(Transaction.Payment(
                      amount: 123,
                      sender: account,
                      recipient: "YAASANKU5CCS2KKAY6BM74EMKLP5HLXPNSOGM7GZCXLSOXY2WZRHEMX5TY"
                    ))
                    .component(Transaction.Note(string: "Test"))
                  let signedTransaction = try transaction.sign(with: account)
            
                  let response = try await node.postTransaction(packed: signedTransaction)
                  
                  print(response)
                } catch {
                  print(error)
                }
              }
            }
            .isSecondary(true)
          }
        }
        .padding(16)
      }
      
      List {
        Button {
          Task.init {
            do {
              let indexer = Indexer(host: "http://192.168.86.250:8980")
              let _ = try await indexer.fetch(path: "/v2/accounts/YAASANKU5CCS2KKAY6BM74EMKLP5HLXPNSOGM7GZCXLSOXY2WZRHEMX5TY/transactions")
              print(String(data: Data(base64Encoded: "VGVzdA==")!, encoding: .utf8)!)
            } catch {
              print(error)
            }
          }
          
        } label: {
          Text("Test")
        }
      }
      
      Spacer()
      
      HStack {
        Action(title: Text("Add using mnemonic phrase")) {
          store.screen = .accountsAddUsingMnemonic
        }
        .isInverted(store.accounts.count > 0)
      }
      .padding(.horizontal, 16)
    } header: {
      Text("Accounts")
    }
    .ignoresSafeArea(.keyboard)
  }
}

struct AccountsView_Previews: PreviewProvider {
  static var previews: some View {
    AccountsView()
  }
}
