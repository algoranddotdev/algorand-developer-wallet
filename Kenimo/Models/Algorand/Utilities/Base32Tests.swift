//
//  Base32Tests.swift
//  ArchWalletTests
//
//  Created by Morgan Wilde on 8/19/22.
//

import XCTest

class Base32Tests: XCTestCase {
  
  func testEncodeEmpty() {
    XCTAssertEqual(Base32.encode(bytes: Data()), "")
  }
  func testEncodePadded() {
    let assertions: [(input: Array<UInt8>, output: String)] = [
      ([0], "AA======"),
      ([0, 0], "AAAA===="),
      ([21, 14], "CUHA===="),
      ([0, 0, 0], "AAAAA==="),
      ([21, 14, 21], "CUHBK==="),
      ([0, 0, 0, 0], "AAAAAAA="),
      ([21, 14, 21, 14], "CUHBKDQ="),
      ([0, 0, 0, 0, 0, 0], "AAAAAAAAAA======"),
      ([1, 1, 1, 1, 1, 1], "AEAQCAIBAE======"),
      ([1, 1, 1, 1, 1, 1, 1], "AEAQCAIBAEAQ===="),
      ([1, 1, 1, 1, 1, 1, 1, 1], "AEAQCAIBAEAQC==="),
      ([1, 1, 1, 1, 1, 1, 1, 1, 1], "AEAQCAIBAEAQCAI=")
    ]
    
    for assertion in assertions {
      XCTAssertEqual(Base32.encode(bytes: Data(assertion.input)), assertion.output)
    }
  }
  func testEncodeNotPadded() {
    let assertions: [(input: Array<UInt8>, output: String)] = [
      ([0, 0, 0, 0, 0], "AAAAAAAA"),
      ([21, 14, 21, 14, 21], "CUHBKDQV"),
      ([1, 1, 1, 1, 1, 1, 1, 1, 1, 1], "AEAQCAIBAEAQCAIB")
    ]
    
    for assertion in assertions {
      XCTAssertEqual(Base32.encode(bytes: Data(assertion.input)), assertion.output)
    }
  }
  
  func testDecodeInvalidInput() {
    XCTAssertThrowsError(try Base32.decode(string: "AA")) { error in
      XCTAssertEqual(error as! Base32Error, Base32Error.invalidInputLength(length: 2))
    }
  }
  func testDecodeEmpty() {
    XCTAssertEqual(try Base32.decode(string: ""), [])
  }
  func testDecodePadded() {
    let assertions: [(input: String, output: Array<UInt8>)] = [
      ("AA======", [0]),
      ("AAAA====", [0, 0]),
      ("CUHA====", [21, 14]),
      ("AAAAA===", [0, 0, 0]),
      ("CUHBK===", [21, 14, 21]),
      ("AAAAAAA=", [0, 0, 0, 0]),
      ("CUHBKDQ=", [21, 14, 21, 14]),
      ("AAAAAAAAAA======", [0, 0, 0, 0, 0, 0]),
      ("AEAQCAIBAE======", [1, 1, 1, 1, 1, 1]),
      ("AEAQCAIBAEAQ====", [1, 1, 1, 1, 1, 1, 1]),
      ("AEAQCAIBAEAQC===", [1, 1, 1, 1, 1, 1, 1, 1]),
      ("AEAQCAIBAEAQCAI=", [1, 1, 1, 1, 1, 1, 1, 1, 1])
    ]
    
    for assertion in assertions {
      XCTAssertEqual(try Base32.decode(string: assertion.input), assertion.output)
    }
  }
  func testDecodeNotPadded() {
    let assertions: [(input: String, output: Array<UInt8>)] = [
      ("AAAAAAAA", [0, 0, 0, 0, 0]),
      ("CUHBKDQV", [21, 14, 21, 14, 21]),
      ("AEAQCAIBAEAQCAIB", [1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
    ]
    
    for assertion in assertions {
      XCTAssertEqual(try Base32.decode(string: assertion.input), assertion.output)
    }
  }
  func testDecodeEmptyAlgorandAddress() {
    XCTAssertEqual(
      try Base32.decode(string: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAY5HFKQ======"),
      Array<UInt8>([
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        12, 116, 229, 84
      ])
    )
  }
  func testDecodeExistingAlgorandAddress() {
    XCTAssertEqual(
      try Base32.decode(string: "CCGJ7X6IAB5X3FDS3SX2BC4UOAOOTLQTY5ZK42K5BXZPLMF6PD3AFQK7NU======"),
      Array<UInt8>([
        16, 140, 159, 223, 200, 0, 123, 125,
        148, 114, 220, 175, 160, 139, 148, 112,
        28, 233, 174, 19, 199, 114, 174, 105,
        93, 13, 242, 245, 176, 190, 120, 246,
        2, 193, 95, 109
      ])
    )
  }
}
