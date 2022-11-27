//
//  AccountTests.swift
//  ArchWalletTests
//
//  Created by Morgan Wilde on 8/21/22.
//

import XCTest

class AccountTests: XCTestCase {
  
  func testInitializationWithInvalidAddress() {
    XCTAssertThrowsError(try Account("")) { error in
      XCTAssertEqual(error as! AccountError, AccountError.invalidAddress)
    }
  }
  func testInitializationWithAddress() throws {
    let account = try Account("CCGJ7X6IAB5X3FDS3SX2BC4UOAOOTLQTY5ZK42K5BXZPLMF6PD3AFQK7NU")
    
    XCTAssertEqual(account.publicKey, Array<UInt8>([
      16, 140, 159, 223, 200, 0, 123, 125,
      148, 114, 220, 175, 160, 139, 148, 112,
      28, 233, 174, 19, 199, 114, 174, 105,
      93, 13, 242, 245, 176, 190, 120, 246
    ]))
    XCTAssertEqual(account.checksum, Array<UInt8>([
      2, 193, 95, 109
    ]))
  }
  func testInitializationWithPrivateKey() throws {
    let account = try Account(privateKeyBytes: [
      113, 23, 254, 216, 30, 228, 167, 202,
      83, 103, 43, 147, 5, 70, 237, 226,
      216, 81, 236, 132, 255, 23, 44, 185,
      25, 179, 201, 189, 74, 201, 201, 118
    ])
    
    XCTAssertEqual(account.address, "RS4JFA7QBSAELIVGCJX6YJZAGJP2HBG63W3NEPUSST3B43Z6BOTPOMTG2U")
  }
  
  func testCreation() {
    let account = Account()
    
    XCTAssertEqual(account.address.count, Constants.Lengths.address)
    XCTAssertEqual(account.publicKey.count, Constants.Lengths.publicKey)
    XCTAssertEqual(account.checksum.count, Constants.Lengths.checksum)
  }
  
  func testSignature() throws {
    let account = try Account(privateKeyBytes: [
      113, 23, 254, 216, 30, 228, 167, 202,
      83, 103, 43, 147, 5, 70, 237, 226,
      216, 81, 236, 132, 255, 23, 44, 185,
      25, 179, 201, 189, 74, 201, 201, 118
    ])
    let payload = Data(Array<UInt8>([
      137, 163, 97, 109, 116, 206, 0, 15,
      66, 64, 163, 102, 101, 101, 205, 3,
      232, 162, 102, 118, 1, 163, 103, 101,
      110, 170, 115, 97, 110, 100, 110, 101,
      116, 45, 118, 49, 162, 103, 104, 196,
      32, 163, 129, 39, 146, 49, 234, 108,
      3, 168, 161, 218, 242, 23, 23, 116,
      153, 58, 101, 24, 169, 171, 176, 157,
      243, 211, 143, 66, 231, 203, 250, 69,
      190, 162, 108, 118, 205, 3, 233, 163,
      114, 99, 118, 196, 32, 39, 183, 167,
      77, 105, 16, 93, 191, 186, 17, 137,
      183, 40, 220, 105, 124, 60, 152, 176,
      155, 123, 30, 78, 107, 66, 15, 3,
      175, 139, 215, 183, 8, 163, 115, 110,
      100, 196, 32, 140, 184, 146, 131, 240,
      12, 128, 69, 162, 166, 18, 111, 236,
      39, 32, 50, 95, 163, 132, 222, 221,
      182, 210, 62, 146, 148, 246, 30, 111,
      62, 11, 166, 164, 116, 121, 112, 101,
      163, 112, 97, 121
    ]))
    let signedData = try account.sign(data: payload)
    
    XCTAssertTrue(try account.verify(signature: signedData, for: payload))
  }
  func testSingatureFromSDK() throws {
    let account = try Account(privateKeyBytes: [
      113, 23, 254, 216, 30, 228, 167, 202,
      83, 103, 43, 147, 5, 70, 237, 226,
      216, 81, 236, 132, 255, 23, 44, 185,
      25, 179, 201, 189, 74, 201, 201, 118
    ])
    let payload = Data(Array<UInt8>([
      84, 88, 137, 163, 97, 109, 116, 206,
      0, 15, 66, 64, 163, 102, 101, 101,
      205, 3, 232, 162, 102, 118, 7, 163,
      103, 101, 110, 170, 115, 97, 110, 100,
      110, 101, 116, 45, 118, 49, 162, 103,
      104, 196, 32, 163, 129, 39, 146, 49,
      234, 108, 3, 168, 161, 218, 242, 23,
      23, 116, 153, 58, 101, 24, 169, 171,
      176, 157, 243, 211, 143, 66, 231, 203,
      250, 69, 190, 162, 108, 118, 205, 3,
      239, 163, 114, 99, 118, 196, 32, 39,
      183, 167, 77, 105, 16, 93, 191, 186,
      17, 137, 183, 40, 220, 105, 124, 60,
      152, 176, 155, 123, 30, 78, 107, 66,
      15, 3, 175, 139, 215, 183, 8, 163,
      115, 110, 100, 196, 32, 140, 184, 146,
      131, 240, 12, 128, 69, 162, 166, 18,
      111, 236, 39, 32, 50, 95, 163, 132,
      222, 221, 182, 210, 62, 146, 148, 246,
      30, 111, 62, 11, 166, 164, 116, 121,
      112, 101, 163, 112, 97, 121
    ]))
    let signedData = Data(Array<UInt8>([
      68, 72, 180, 6, 125, 157, 233, 47,
      201, 124, 54, 14, 12, 180, 72, 89,
      191, 31, 42, 55, 229, 140, 46, 47,
      178, 147, 239, 146, 130, 3, 179, 7,
      125, 9, 141, 144, 40, 148, 151, 208,
      204, 242, 172, 238, 121, 46, 162, 240,
      138, 12, 11, 224, 245, 154, 80, 38,
      56, 146, 68, 142, 112, 174, 82, 7
    ]))
    
    XCTAssertTrue(try account.verify(signature: signedData, for: payload))
  }
//  func testPayloadAgainstSDK() throws {
//    let account = try Account(privateKeyBytes: [
//      113, 23, 254, 216, 30, 228, 167, 202,
//      83, 103, 43, 147, 5, 70, 237, 226,
//      216, 81, 236, 132, 255, 23, 44, 185,
//      25, 179, 201, 189, 74, 201, 201, 118
//    ])
//    let localPayload = try account.send()
//    print(Array(localPayload))
//    let sdkPayload = Data(Array<UInt8>([
//      130, 163, 115, 105, 103, 196, 64, 125,
//      153, 123, 175, 217, 55, 207, 178, 27,
//      23, 73, 249, 222, 38, 183, 142, 2,
//      41, 14, 52, 90, 159, 53, 31, 194,
//      62, 65, 81, 226, 228, 53, 135, 50,
//      29, 253, 171, 201, 192, 92, 46, 49,
//      100, 35, 168, 194, 38, 200, 131, 177,
//      165, 89, 231, 226, 236, 22, 176, 214,
//      246, 46, 13, 8, 21, 231, 10, 163,
//      116, 120, 110, 137, 163, 97, 109, 116,
//      206, 0, 15, 66, 64, 163, 102, 101,
//      101, 205, 3, 232, 162, 102, 118, 8,
//      163, 103, 101, 110, 170, 115, 97, 110,
//      100, 110, 101, 116, 45, 118, 49, 162,
//      103, 104, 196, 32, 163, 129, 39, 146,
//      49, 234, 108, 3, 168, 161, 218, 242,
//      23, 23, 116, 153, 58, 101, 24, 169,
//      171, 176, 157, 243, 211, 143, 66, 231,
//      203, 250, 69, 190, 162, 108, 118, 205,
//      3, 240, 163, 114, 99, 118, 196, 32,
//      39, 183, 167, 77, 105, 16, 93, 191,
//      186, 17, 137, 183, 40, 220, 105, 124,
//      60, 152, 176, 155, 123, 30, 78, 107,
//      66, 15, 3, 175, 139, 215, 183, 8,
//      163, 115, 110, 100, 196, 32, 140, 184,
//      146, 131, 240, 12, 128, 69, 162, 166,
//      18, 111, 236, 39, 32, 50, 95, 163,
//      132, 222, 221, 182, 210, 62, 146, 148,
//      246, 30, 111, 62, 11, 166, 164, 116,
//      121, 112, 101, 163, 112, 97, 121
//    ]))
//    
//    // Compare {"sig": Data(...
//    XCTAssertEqual(localPayload[0...6], sdkPayload[0...6])
//    // Ignore signatures binary data.
//    // XCTAssertEqual(localPayload[7...70], sdkPayload[7...70])
//    // Compare "txn": {...}}
//    XCTAssertEqual(localPayload[71...], sdkPayload[71...])
//  }
  
}
