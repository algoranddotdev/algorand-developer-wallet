//
//  Node.swift
//  ArchWallet
//
//  Created by Morgan Wilde on 8/28/22.
//

import Foundation

//enum Network: String {
//  case sandbox
//  case testNet
//  case mainNet
//}

struct Node {
  
  enum RequestError: Error, Equatable {
    case invalidAPIToken
    
    case noNetworkSelected
    case undefinedSandboxUrl
    case invalidSignature
    case emptyTransactionGroup
    case unknown
    
    case unknownTransactionType
  }
  
  struct ErrorResponse: Codable {
    let message: String
  }
  
  let network: Network
  
  func fetch(
    path: String,
    method: String = "GET",
    body: Data? = nil
  ) async throws -> Data {
    var request = network.request(for: path)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let body = body {
      request.httpBody = body
    }
    
    let (data, response) = try await URLSession.shared.data(for: request) as! (Data, HTTPURLResponse)
    let responseDecoded = String(data: data, encoding: .utf8)!
    print(response)
    print(responseDecoded)
    
    switch (response.statusCode, try? JSONDecoder().decode(ErrorResponse.self, from: data)) {
    case (401, let response) where response?.message == "Invalid API Token":
      throw RequestError.invalidAPIToken
    default:
      break
    }
    
    return data
  }
  
  func getTransactionParameters() async throws -> Response.TransactionsParameters {
    let data = try await fetch(path: "/v2/transactions/params")
    let response = try JSONDecoder().decode(Response.TransactionsParameters.self, from: data)
    
    return response
  }
  
  func postTransaction(packed: [UInt8]) async throws -> Response.TransactionIdentifier {
    let data = try await fetch(
      path: "/v2/transactions",
      method: "POST",
      body: Data(packed)
    )
    
    do {
      let response = try JSONDecoder().decode(Response.TransactionIdentifier.self, from: data)
      
      return response
    } catch {
      // Parse this RegEx...
      // transaction \{(.*)\} invalid : (.*)
      throw RequestError.unknownTransactionType
    }
  }
  
//  static func getTransactionParams() async -> TransactionsParamsResponse? {
//    guard
//      let data = try? await fetch(path: "/v2/transactions/params"),
//      let response: TransactionsParamsResponse = try? parse(data)
//    else {
//      return nil
//    }
//
//    return response
//  }
//  static func postTransaction(packed: Data) async -> TransactionResponse? {
//    guard
//      let data = try? await fetch(path: "/v2/transactions", method: "POST", body: packed),
//      let response: TransactionResponse = try? parse(data)
//    else {
//      return nil
//    }
//
//    return response
//  }
  
//  static func fetch(
//    path: String,
//    method: String = "GET",
//    body: Data? = nil
//  ) async throws -> Data {
//    return Data()
//////    let network = Network.sandbox
////    print("selected network: ")
////    print(UserDefaults.standard.string(forKey: "Kenimo.Algorand.network"))
//////    print(networkString != nil ? Network(rawValue: networkString) : "no network")
////    guard
////      let networkString = UserDefaults.standard.string(forKey: "Kenimo.Algorand.network"),
////      let network = Network(rawValue: networkString)
////    else {
////      throw RequestError.noNetworkSelected
////    }
////
////    let host: String
////    switch network {
////    case .sandbox:
////      guard let sandboxUrl = UserDefaults.standard.string(forKey: "Kenimo.Algorand.network.host") else {
////        throw RequestError.undefinedSandboxUrl
////      }
////      host = sandboxUrl
////    case .testNet:
////      host = "https://node.testnet.algoexplorerapi.io"
////    case .mainNet:
////      host = "https://node.algoexplorerapi.io"
////    }
////
////    let url = URL(string: "\(host)\(path)")!
////    var request = URLRequest(url: url)
////    request.httpMethod = method
////    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
////
////    if network == .sandbox {
////      request.setValue("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", forHTTPHeaderField: "X-Algo-API-Token")
////    }
////
////    if let body = body {
////      request.httpBody = body
////    }
////
////    let (data, response) = try await URLSession.shared.data(for: request) as! (Data, HTTPURLResponse)
////    let responseDecoded = String(data: data, encoding: .utf8)!
////    print(response)
////    print(responseDecoded)
////
////    let decoder = JSONDecoder()
////
////    if response.statusCode == 400 {
////      let error = try decoder.decode(ErrorResponse.self, from: data)
////
////      switch error.message {
////      case "At least one signature didn't pass verification":
////        throw RequestError.invalidSignature
////      case "empty txgroup":
////        throw RequestError.emptyTransactionGroup
////      default:
////        throw RequestError.unknown
////      }
////    }
////
////    return data
//  }
  static func parse<T: Decodable>(_ data: Data) throws -> T {
    let decoder = JSONDecoder()
    return try decoder.decode(T.self, from: data)
  }
}

extension Node {
  enum Response {
    struct TransactionsParameters: Codable {
      enum CodingKeys: String, CodingKey {
        case fee
        case consensusVersion = "consensus-version"
        case genesisHash = "genesis-hash"
        case genesisId = "genesis-id"
        case lastRound = "last-round"
        case minFee = "min-fee"
      }
      
      let fee: Int
      let minFee: Int
      let consensusVersion: String
      let genesisId: String
      let genesisHash: String
      let lastRound: Int
    }
    
    struct TransactionIdentifier: Codable {
      enum CodingKeys: String, CodingKey {
        case id = "txId"
      }
      
      let id: String
    }
  }
}
