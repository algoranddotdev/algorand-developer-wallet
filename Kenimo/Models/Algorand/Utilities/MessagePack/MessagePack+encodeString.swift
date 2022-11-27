//
//  MessagePackString.swift
//  ArchWallet
//
//  Created by Morgan Wilde on 8/26/22.
//

import Foundation

enum MessagePackStringError: Error, Equatable {
  case unsupportedLength
}

extension MessagePack {
  static func encode(string: String) throws -> [UInt8] {
    var encoded = Array<UInt8>()
    
    switch string.count {
    case 0...31:
      encoded = [
        0b1010_0000 | (UInt8(string.count) & 0b0001_1111)
      ]
    case 32...(1 << 8) - 1:
      encoded = [
        0xd9,
        UInt8(string.count)
      ]
    case (1 << 8)...(1 << 16) - 1:
      let sizeAsBytes = withUnsafeBytes(of: UInt16(string.count).bigEndian, Array<UInt8>.init)
      encoded = [0xda] + sizeAsBytes
    case (1 << 16)...(1 << 32) - 1:
      let sizeAsBytes = withUnsafeBytes(of: UInt32(string.count).bigEndian, Array<UInt8>.init)
      encoded = [0xdb] + sizeAsBytes
    default:
      throw MessagePackStringError.unsupportedLength
    }
    
    // Append string bytes.
    encoded += Array(string.utf8)
    
    return encoded
  }
}
