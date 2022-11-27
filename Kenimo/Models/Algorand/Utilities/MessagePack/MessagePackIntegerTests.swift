//
//  MessagePackIntTests.swift
//  ArchWalletTests
//
//  Created by Morgan Wilde on 8/26/22.
//

import XCTest

class MessagePackIntegerTests: XCTestCase {
  
  func testIntegerZero() {
    XCTAssertEqual(MessagePack.encode(integer: 0), [0])
  }
  func testInteger7BitPositive() {
    for integer in 0..<(1 << 7) {
      XCTAssertEqual(MessagePack.encode(integer: integer), [UInt8(integer)])
    }
  }
  func testInteger5BitNegative() {
    for integer in (-31)...(-1) {
      XCTAssertEqual(MessagePack.encode(integer: integer), withUnsafeBytes(of: Int8(integer), Array<UInt8>.init))
    }
  }
  
  func testInteger8BitUnsigned() {
    for integer in 0b1000_0000...0b1111_1111 {
      XCTAssertEqual(MessagePack.encode(integer: UInt(integer)), [0xcc, UInt8(integer)])
    }
  }
  func testInteger16BitUnsigned() {
    let assertions: [(input: UInt, output: Array<UInt8>)] = [
      (0b0001_0000_0000, [0xcd, 1, 0]),
      (0b0010_0000_0000, [0xcd, 2, 0]),
      (0b0100_0000_0000, [0xcd, 4, 0]),
      (0b1000_0000_0000, [0xcd, 8, 0]),
      (0b0001_0000_0000_0000, [0xcd, 16, 0]),
      (0b0010_0000_0000_0000, [0xcd, 32, 0]),
      (0b0100_0000_0000_0000, [0xcd, 64, 0]),
      (0b1000_0000_0000_0000, [0xcd, 128, 0]),
      (0b1111_1111_1111_1111, [0xcd, 255, 255]),
    ]
    
    for assertion in assertions {
      XCTAssertEqual(MessagePack.encode(integer: assertion.input), assertion.output)
    }
  }
  func testInteger32BitUnsigned() {
    let assertions: [(input: UInt, output: Array<UInt8>)] = [
      (0b0001_0000_0000_0000_0000, [0xce, 0, 1, 0, 0]),
      (0b0010_0000_0000_0000_0000, [0xce, 0, 2, 0, 0]),
      (0b0100_0000_0000_0000_0000, [0xce, 0, 4, 0, 0]),
      (0b1000_0000_0000_0000_0000, [0xce, 0, 8, 0, 0]),
      (0b0001_0000_0000_0000_0000_0000, [0xce, 0, 16, 0, 0]),
      (0b0010_0000_0000_0000_0000_0000, [0xce, 0, 32, 0, 0]),
      (0b0100_0000_0000_0000_0000_0000, [0xce, 0, 64, 0, 0]),
      (0b1000_0000_0000_0000_0000_0000, [0xce, 0, 128, 0, 0]),
      (0b0001_0000_0000_0000_0000_0000_0000, [0xce, 1, 0, 0, 0]),
      (0b0010_0000_0000_0000_0000_0000_0000, [0xce, 2, 0, 0, 0]),
      (0b0100_0000_0000_0000_0000_0000_0000, [0xce, 4, 0, 0, 0]),
      (0b1000_0000_0000_0000_0000_0000_0000, [0xce, 8, 0, 0, 0]),
      (0b0001_0000_0000_0000_0000_0000_0000_0000, [0xce, 16, 0, 0, 0]),
      (0b0010_0000_0000_0000_0000_0000_0000_0000, [0xce, 32, 0, 0, 0]),
      (0b0100_0000_0000_0000_0000_0000_0000_0000, [0xce, 64, 0, 0, 0]),
      (0b1000_0000_0000_0000_0000_0000_0000_0000, [0xce, 128, 0, 0, 0]),
    ]
    
    for assertion in assertions {
      XCTAssertEqual(MessagePack.encode(integer: assertion.input), assertion.output)
    }
  }
  func testInteger64BitUnsigned() {
    let assertions: [(input: UInt, output: Array<UInt8>)] = [
      (0x01_0000_0000, [0xcf, 0, 0, 0, 1, 0, 0, 0, 0]),
      (0x02_0000_0000, [0xcf, 0, 0, 0, 2, 0, 0, 0, 0]),
      (0x04_0000_0000, [0xcf, 0, 0, 0, 4, 0, 0, 0, 0]),
      (0x08_0000_0000, [0xcf, 0, 0, 0, 8, 0, 0, 0, 0]),
      (0x10_0000_0000, [0xcf, 0, 0, 0, 16, 0, 0, 0, 0]),
      (0x20_0000_0000, [0xcf, 0, 0, 0, 32, 0, 0, 0, 0]),
      (0x40_0000_0000, [0xcf, 0, 0, 0, 64, 0, 0, 0, 0]),
      (0x80_0000_0000, [0xcf, 0, 0, 0, 128, 0, 0, 0, 0]),
      (0x0100_0000_0000, [0xcf, 0, 0, 1, 0, 0, 0, 0, 0]),
      (0x0200_0000_0000, [0xcf, 0, 0, 2, 0, 0, 0, 0, 0]),
      (0x0400_0000_0000, [0xcf, 0, 0, 4, 0, 0, 0, 0, 0]),
      (0x0800_0000_0000, [0xcf, 0, 0, 8, 0, 0, 0, 0, 0]),
      (0x1000_0000_0000, [0xcf, 0, 0, 16, 0, 0, 0, 0, 0]),
      (0x2000_0000_0000, [0xcf, 0, 0, 32, 0, 0, 0, 0, 0]),
      (0x4000_0000_0000, [0xcf, 0, 0, 64, 0, 0, 0, 0, 0]),
      (0x8000_0000_0000, [0xcf, 0, 0, 128, 0, 0, 0, 0, 0]),
      (0x01_0000_0000_0000, [0xcf, 0, 1, 0, 0, 0, 0, 0, 0]),
      (0x02_0000_0000_0000, [0xcf, 0, 2, 0, 0, 0, 0, 0, 0]),
      (0x04_0000_0000_0000, [0xcf, 0, 4, 0, 0, 0, 0, 0, 0]),
      (0x08_0000_0000_0000, [0xcf, 0, 8, 0, 0, 0, 0, 0, 0]),
      (0x10_0000_0000_0000, [0xcf, 0, 16, 0, 0, 0, 0, 0, 0]),
      (0x20_0000_0000_0000, [0xcf, 0, 32, 0, 0, 0, 0, 0, 0]),
      (0x40_0000_0000_0000, [0xcf, 0, 64, 0, 0, 0, 0, 0, 0]),
      (0x80_0000_0000_0000, [0xcf, 0, 128, 0, 0, 0, 0, 0, 0]),
      (0x0100_0000_0000_0000, [0xcf, 1, 0, 0, 0, 0, 0, 0, 0]),
      (0x0200_0000_0000_0000, [0xcf, 2, 0, 0, 0, 0, 0, 0, 0]),
      (0x0400_0000_0000_0000, [0xcf, 4, 0, 0, 0, 0, 0, 0, 0]),
      (0x0800_0000_0000_0000, [0xcf, 8, 0, 0, 0, 0, 0, 0, 0]),
      (0x1000_0000_0000_0000, [0xcf, 16, 0, 0, 0, 0, 0, 0, 0]),
      (0x2000_0000_0000_0000, [0xcf, 32, 0, 0, 0, 0, 0, 0, 0]),
      (0x4000_0000_0000_0000, [0xcf, 64, 0, 0, 0, 0, 0, 0, 0]),
      (0x8000_0000_0000_0000, [0xcf, 128, 0, 0, 0, 0, 0, 0, 0]),
    ]
    
    for assertion in assertions {
      XCTAssertEqual(MessagePack.encode(integer: assertion.input), assertion.output)
    }
  }
  
}
