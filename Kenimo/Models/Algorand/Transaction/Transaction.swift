//
//  Transaction.swift
//  ArchWallet
//
//  Created by Morgan Wilde on 8/26/22.
//

import Foundation


struct Transaction {
  static func pack(transaction: MessagePackable, signer: Account) throws -> [UInt8] {
    let payload: MessagePackable = [
      "txn": transaction,
      "sig": try signer.sign(data: Data(
        Array("TX".utf8) +
        transaction.packed()
      ))
    ]
    
    return payload.packed()
  }
  
  
//  var payload: [String: Codable] = [:]
  
//  init() {
//    payload = [
//      "amt": 1000000,
//      "fee": 1000,
//      "fv": 8,
//      "lv": 1008,
//      "snd": Array<UInt8>([
//        140,184,146,131,240,12,128,69,162,166,18,111,236,39,32,50,95,163,132,222,221,182,210,62,146,148,246,30,111,62,11,166
//      ]),
//      "type": "pay",
//      "gen": "sandnet-v1",
//      "gh": Array<UInt8>([
//        163,129,39,146,49,234,108,3,168,161,218,242,23,23,116,153,58,101,24,169,171,176,157,243,211,143,66,231,203,250,69,190
//      ]),
//      "rcv": Array<UInt8>([
//        39,183,167,77,105,16,93,191,186,17,137,183,40,220,105,124,60,152,176,155,123,30,78,107,66,15,3,175,139,215,183,8
//      ])
//    ]
//  }
  
  
  static func build(components: [TransactionComponent]) -> MessagePackable {
    var buffer: [String: MessagePackable] = [:]
    for component in components {
      buffer.merge(component.packable) { (_, new) in new }
    }
 
    // TODO: When forming transactions, it's key to always remove zero values, otherwise the thing throws a signature mismatch error.
    // This is because I sign bytes that include the zero value, while the node discards zero values before verying against signature.
    
    // Remove all zero value
    var sanitized: [String: MessagePackable] = [:]
    for key in buffer.keys {
      if let number = buffer[key] as? UInt, number != 0 {
        sanitized[key] = number
      } else if let number = buffer[key] as? Int, number != 0  {
        sanitized[key] = number
      } else if let string = buffer[key] as? String, string.count > 0 {
        sanitized[key] = string
      } else if let data = buffer[key] as? Data, data.count > 0 {
        sanitized[key] = data
      } else if let bytes = buffer[key] as? [UInt8], bytes.count > 0 {
        sanitized[key] = bytes
      } else if let dictionary = buffer[key] as? [String: MessagePackable], dictionary.keys.count > 0 {
        sanitized[key] = dictionary
      }
    }
    
    return buffer
  }
  
  var components: [TransactionComponent] = []
  var packable: [String: MessagePackable] {
    var buffer: [String: MessagePackable] = [:]
    for component in components {
      buffer.merge(component.packable) { (_, new) in new }
    }
 
    // TODO: When forming transactions, it's key to always remove zero values, otherwise the thing throws a signature mismatch error.
    // This is because I sign bytes that include the zero value, while the node discards zero values before verying against signature.
    
    // Remove all zero value
    var sanitized: [String: MessagePackable] = [:]
    for key in buffer.keys {
      if let number = buffer[key] as? UInt, number != 0 {
        sanitized[key] = number
      } else if let number = buffer[key] as? Int, number != 0  {
        sanitized[key] = number
      } else if let string = buffer[key] as? String, string.count > 0 {
        sanitized[key] = string
      } else if let data = buffer[key] as? Data, data.count > 0 {
        sanitized[key] = data
      } else if let bytes = buffer[key] as? [UInt8], bytes.count > 0 {
        sanitized[key] = bytes
      } else if let dictionary = buffer[key] as? [String: MessagePackable], dictionary.keys.count > 0 {
        sanitized[key] = dictionary
      }
    }
    
    return buffer
  }
  
  func component(_ component: TransactionComponent) -> Transaction {
    return Transaction(components: components + [component])
  }
  
  func sign(with account: Account) throws -> [UInt8] {
    let payload: MessagePackable = [
      "txn": packable,
      "sig": try account.sign(data: Data(
        Array("TX".utf8) +
        packable.packed()
      ))
    ]
    
    return payload.packed()
  }
}

protocol TransactionComponent {
  var packable: [String: MessagePackable] { get }
}

extension Transaction {
  struct Base: TransactionComponent {
    static func makeInitialized(for node: Node) async throws -> Transaction.Base {
      let paramaters = try await node.getTransactionParameters()
      return Transaction.Base(
        genesisId: paramaters.genesisId,
        genesisHash: paramaters.genesisHash,
        fee: paramaters.minFee,
        lastRound: paramaters.lastRound
      )
    }
    
    var genesisId: String
    var genesisHash: String
    var fee: Int
    var lastRound: Int
    
    var packable: [String: MessagePackable] {
      return [
        "gen": genesisId,
        "gh": Data(base64Encoded: genesisHash)!,
        "fv": lastRound,
        "lv": lastRound + 1,
        "fee": fee
      ]
    }
  }
  struct Payment: TransactionComponent {
    var amount: Int
    var sender: Account
    var recipient: String
    
    var packable: [String : MessagePackable] {
      return [
        "type": "pay",
        "amt": amount,
        "snd": Array(sender.addressDecoded[..<32]),
        "rcv": Array(Base32.decode(algorandAddress: recipient)[..<32])
      ]
    }
  }
}

extension Transaction {
  struct Note: TransactionComponent {
    var string: String
    
    var packable: [String : MessagePackable] {
      return [
        "note": Data(string.utf8)
      ]
    }
  }
}
