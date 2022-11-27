//
//  MessagePack.swift
//  ArchWallet
//
//  Created by Morgan Wilde on 8/26/22.
//

import Foundation

enum MessagePackError: Error, Equatable {
  
}

struct MessagePack {
  
  struct FixedFormat {
    static let positiveInteger: ClosedRange<UInt8> = 0x00...0x7f
    static let negativeInteger: ClosedRange<UInt8> = 0xe0...0xff
    static let map: ClosedRange<UInt8> = 0x80...0x8f
    static let array: ClosedRange<UInt8> = 0x90...0x9f
    static let string: ClosedRange<UInt8> = 0xa0...0xbf
  }
  
  enum Format: UInt8 {
    case unsignedInteger8 = 0xcc
    case unsignedInteger16 = 0xcd
    case unsignedInteger32 = 0xce
    case unsignedInteger64 = 0xcf
    
    case integer8 = 0xd0
    case integer16 = 0xd1
    case integer32 = 0xd2
    case integer64 = 0xd3
    
    case string8 = 0xd9
    case string16 = 0xda
    case string32 = 0xdb
    
    case binary8 = 0xc4
    case binary16 = 0xc5
    case binary32 = 0xc6
    
    case map16 = 0xde
    case map32 = 0xdf
  }
  
  static func pack(_ thing: MessagePackable) -> [UInt8] {
    return thing.packed()
  }
}

protocol MessagePackable {
  func packed() -> [UInt8]
}
extension UInt: MessagePackable {
  func packed() -> [UInt8] {
    let bitCount = 64 - leadingZeroBitCount
    var result = Array<UInt8>()
    
    if bitCount <= 7 {
      result.append(UInt8(self))
    } else if bitCount <= 8 {
      result.append(MessagePack.Format.unsignedInteger8.rawValue)
      result += [UInt8(self)]
    } else if bitCount <= 16 {
      result.append(MessagePack.Format.unsignedInteger16.rawValue)
      result += withUnsafeBytes(of: UInt16(self).bigEndian, Array<UInt8>.init)
    } else if bitCount <= 32 {
      result.append(MessagePack.Format.unsignedInteger32.rawValue)
      result += withUnsafeBytes(of: UInt32(self).bigEndian, Array<UInt8>.init)
    } else if bitCount <= 64 {
      result.append(MessagePack.Format.unsignedInteger64.rawValue)
      result += withUnsafeBytes(of: UInt64(self).bigEndian, Array<UInt8>.init)
    }
    
    return result
  }
}

extension Int: MessagePackable {
  func packed() -> [UInt8] {
    if self < 0 {
      // Use the signed integer format only for negative integers.
      let bitCount = 64 - UInt(abs(self)).leadingZeroBitCount
      var result = Array<UInt8>()
      
      if bitCount <= 5 {
        result += withUnsafeBytes(of: Int8(self).bigEndian, Array<UInt8>.init)
      } else if bitCount < 8 {
        result.append(MessagePack.Format.integer8.rawValue)
        result += withUnsafeBytes(of: Int8(self).bigEndian, Array<UInt8>.init)
      } else if bitCount < 16 {
        result.append(MessagePack.Format.integer16.rawValue)
        result += withUnsafeBytes(of: Int16(self).bigEndian, Array<UInt8>.init)
      } else if bitCount < 32 {
        result.append(MessagePack.Format.integer32.rawValue)
        result += withUnsafeBytes(of: Int32(self).bigEndian, Array<UInt8>.init)
      } else {
        result.append(MessagePack.Format.integer64.rawValue)
        result += withUnsafeBytes(of: Int64(self).bigEndian, Array<UInt8>.init)
      }
      
      return result
    } else {
      // All positive integers are formatted as unsigned integers.
      return UInt(self).packed()
    }
  }
}

extension String: MessagePackable {
  func packed() -> [UInt8] {
    let lengthBitCount = 64 - count.leadingZeroBitCount
    var result = Array<UInt8>()
    
    if count < 32 {
      result.append(MessagePack.FixedFormat.string.lowerBound | UInt8(count))
    } else if lengthBitCount <= 8 {
      result.append(MessagePack.Format.string8.rawValue)
    } else if lengthBitCount <= 16 {
      result.append(MessagePack.Format.string16.rawValue)
    } else if lengthBitCount <= 32 {
      result.append(MessagePack.Format.string32.rawValue)
    } else {
      // Future throw
    }
    
    return result + Array(utf8)
  }
}

extension Data: MessagePackable {
  func packed() -> [UInt8] {
    let lengthBitCount = 64 - count.leadingZeroBitCount
    var result = Array<UInt8>()
    
    if lengthBitCount <= 8 {
      result.append(MessagePack.Format.binary8.rawValue)
      result += Swift.withUnsafeBytes(of: UInt8(count).bigEndian, Array<UInt8>.init)
    } else if lengthBitCount <= 16 {
      result.append(MessagePack.Format.binary16.rawValue)
      result += Swift.withUnsafeBytes(of: UInt16(count).bigEndian, Array<UInt8>.init)
    } else if lengthBitCount <= 32 {
      result.append(MessagePack.Format.binary32.rawValue)
      result += Swift.withUnsafeBytes(of: UInt32(count).bigEndian, Array<UInt8>.init)
    }
    
    return result + Array(self)
  }
}
extension Array: MessagePackable where Element == UInt8 {
  func packed() -> [UInt8] {
    return Data(self).packed()
  }
}

// MessagePack map key can be any MessagePack type, but Algorand exclusively
// uses string keys, so I will use that to reduce the scope here.
// Also, I'm sorting keys, which is the only option used by Algorand.
extension Dictionary: MessagePackable where Key: Comparable {
  func packed() -> [UInt8] {
    let lengthBitCount = 64 - count.leadingZeroBitCount
    var result = Array<UInt8>()
    
    if lengthBitCount <= 4 {
      result.append(MessagePack.FixedFormat.map.lowerBound | UInt8(count))
    } else if lengthBitCount <= 16 {
      result.append(MessagePack.Format.map16.rawValue)
    } else if lengthBitCount <= 32 {
      result.append(MessagePack.Format.map32.rawValue)
    }
    
    for key in self.keys.sorted(by: <) {
      if let packableKey = key as? MessagePackable,
         let packableValue = self[key] as? MessagePackable
      {
//        print(packableKey, packableKey.packed())
//        print(packableValue.packed())
        result += packableKey.packed() + packableValue.packed()
      }
    }
    
    return result
  }
}
