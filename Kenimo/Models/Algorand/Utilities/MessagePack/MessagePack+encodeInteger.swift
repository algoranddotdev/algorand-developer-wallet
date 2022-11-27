//
//  MessagePackInt.swift
//  ArchWallet
//
//  Created by Morgan Wilde on 8/26/22.
//

import Foundation

extension MessagePack {
  static func encode(integer: Int) -> [UInt8] {
    var encoded = Array<UInt8>()
    
    if integer >= 0 {
      switch integer {
      case 0b0000_0000...0b0111_1111:
        // Positive fixint stores 7-bit positive integer.
        encoded = [UInt8(integer)]
      case 0b1000_0000...0b1111_1111:
        encoded = [0xcc, UInt8(integer)]
      case 0b0001_0000_0000...0b1111_1111_1111_1111:
        encoded = [0xcd] + withUnsafeBytes(of: UInt16(integer).bigEndian, Array<UInt8>.init)
      case 0b0001_0000_0000_0000_0000...0xffff_ffff:
        encoded = [0xce] + withUnsafeBytes(of: UInt32(integer).bigEndian, Array<UInt8>.init)
      case 0x01_0000_0000...Int.max:
        encoded = [0xce] + withUnsafeBytes(of: UInt32(integer).bigEndian, Array<UInt8>.init)
      default:
        encoded = []
      }
    } else {
      switch integer {
      case (-31)...(-1):
        // Negative fixint stores 5-bit negative integer
        encoded = withUnsafeBytes(of: Int8(integer), Array<UInt8>.init)
      default:
        encoded = []
      }
    }
    
    
    return encoded
  }
  static func encode(integer: UInt) -> [UInt8] {
    var encoded = Array<UInt8>()
    
    switch integer {
    case 0b0000_0000...0b0111_1111:
      // Positive fixint stores 7-bit positive integer.
      encoded = [UInt8(integer)]
    case 0b1000_0000...0b1111_1111:
      encoded = [0xcc, UInt8(integer)]
    case 0b0001_0000_0000...0b1111_1111_1111_1111:
      encoded = [0xcd] + withUnsafeBytes(of: UInt16(integer).bigEndian, Array<UInt8>.init)
    case 0b0001_0000_0000_0000_0000...0xffff_ffff:
      encoded = [0xce] + withUnsafeBytes(of: UInt32(integer).bigEndian, Array<UInt8>.init)
    case 0x01_0000_0000...UInt.max:
      encoded = [0xcf] + withUnsafeBytes(of: integer.bigEndian, Array<UInt8>.init)
    default:
      encoded = []
    }
    
    
    return encoded
  }
}
