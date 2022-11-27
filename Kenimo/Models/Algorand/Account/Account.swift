//
//  Account.swift
//  ArchWallet
//
//  Created by Morgan Wilde on 8/21/22.
//

import Foundation
import CryptoKit

enum AccountError: Error, Equatable {
  case invalidAddress
  case invalidChecksum
}

enum Constants {
  enum Lengths {
    static let publicKey = 32
    static let checksum = 4
    static let address = 58
  }
}

struct Account: Identifiable {
  
  var id: String {
    return address
  }
  
  var address: String
  var addressDecoded: [UInt8] {
    // It's not possible to initialize an Account without a valid Base32
    // address, so it's safe to force-unwrap this throwable function.
    return Base32.decode(algorandAddress: address)
  }
  
  var privateKey: [UInt8]?
  var publicKey: [UInt8]
  var checksum: [UInt8]
  
  init() {
    self.init(key: Curve25519.Signing.PrivateKey())
  }
  init(privateKeyBytes: [UInt8]) throws {
    self.init(key: try Curve25519.Signing.PrivateKey(rawRepresentation: privateKeyBytes))
  }
  init(key: Curve25519.Signing.PrivateKey) {
    privateKey = Array<UInt8>(key.rawRepresentation)
    publicKey = Array<UInt8>(key.publicKey.rawRepresentation)
    
    let addressHash = Sha512Slash256.hash(bytes: publicKey)
    checksum = Array<UInt8>(addressHash[(Constants.Lengths.publicKey - Constants.Lengths.checksum)..<Constants.Lengths.publicKey])
    
    let addressRaw = Base32.encode(bytes: publicKey + checksum)
    address = String(addressRaw[addressRaw.startIndex..<addressRaw.index(addressRaw.startIndex, offsetBy: Constants.Lengths.address)])
  }
  init(_ possibleAddress: String) throws {
    do {
      let decoded = try Base32.decode(string: "\(possibleAddress)======")
      let publicKey = Array(decoded[0..<Constants.Lengths.publicKey])
      let checksum = Array(decoded[Constants.Lengths.publicKey...])
      
      let hashedPublicKey = Sha512Slash256.hash(bytes: publicKey)
      let computedChecksum = hashedPublicKey[(Constants.Lengths.publicKey - Constants.Lengths.checksum)...]
      
      if !checksum.elementsEqual(computedChecksum) {
        throw AccountError.invalidChecksum
      }
      
      // At this point we know that the address is valid.
      address = possibleAddress
      self.publicKey = publicKey
      self.checksum = checksum
    } catch Base32Error.invalidInputLength(length: _) {
      throw AccountError.invalidAddress
    }
  }
  
  func sign(data: Data) throws -> Data {
    let key = try Curve25519.Signing.PrivateKey(rawRepresentation: privateKey!)
    let signed = try key.signature(for: data)
//    print(signed.map { UInt8($0) })
    
    return signed
  }
  func verify(signature: Data, for data: Data) throws -> Bool {
    let key = try Curve25519.Signing.PublicKey(rawRepresentation: publicKey)
    
    return key.isValidSignature(signature, for: data)
  }
//  func pay(amount: Int, to recipient: String, with transaction: Transaction) -> Transaction {
//    
//  }
  func send(recipient: String, amount: Int) async throws -> Data {
    return Data()
//    let params = await Node.getTransactionParams()
//    print(params)
//    print(address)
//    print(recipient)
//    let message: MessagePackable = [
//      "amt": amount,
//      "fee": 1000,
//      "fv": params!.lastRound,
//      "lv": params!.lastRound + 1000,
//      "snd": Array(addressDecoded[..<32]),
//      "type": "pay",
//      "gen": params!.genesisId,
//      "gh": Data(base64Encoded: params!.genesisHash)!,
//      "rcv": Array(Base32.decode(algorandAddress: recipient)[..<32])
//    ]
//
//    let payload: MessagePackable = [
//      "sig": try sign(data: Data(Array("TX".utf8) + MessagePack.pack(message))),
//      "txn": message
//    ]
//
//    return Data(MessagePack.pack(payload))
  }
}
