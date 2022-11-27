//
//  MessagePackStringTests.swift
//  ArchWalletTests
//
//  Created by Morgan Wilde on 8/26/22.
//

import XCTest

class MessagePackStringTests: XCTestCase {
  
  func testEmptyString() throws {
    XCTAssertEqual(try MessagePack.encode(string: ""), [160])
  }
  func testStringOfLength1() throws {
    XCTAssertEqual(try MessagePack.encode(string: "a"), [161, 97])
  }
  func testStringOfLength32() throws {
    XCTAssertEqual(
      try MessagePack.encode(string: String(repeating: "a", count: 32)),
      [
        217, 32, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97
      ]
    )
  }
  func testStringOfLength256() throws {
    XCTAssertEqual(
      try MessagePack.encode(string: String(repeating: "a", count: 256)),
      [
        218, 1, 0, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97, 97, 97, 97, 97, 97,
        97, 97, 97
      ]
    )
  }
  func testStringOfLength65536() throws {
    let encoded = try MessagePack.encode(string: String(repeating: "a", count: 1 << 16))
    XCTAssertEqual(encoded[0..<5], [219, 0, 1, 0, 0])
  }
  
  func testStringOfUnsupportedLength() throws {
    // This test takes over 90 seconds on my super powerful Mac, only redo it if major changes made.
    try XCTSkipIf(true)
    XCTAssertThrowsError(try MessagePack.encode(string: String(repeating: "a", count: 1 << 32))) { error in
      XCTAssertEqual(error as! MessagePackStringError, MessagePackStringError.unsupportedLength)
    }
  }
  
}
