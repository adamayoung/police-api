//
//  JSONSerialiserTests.swift
//  PoliceDataKit
//
//  Copyright © 2024 Adam Young.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an AS IS BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

@testable import PoliceDataKit
import XCTest

final class JSONSerialiserTests: XCTestCase {

    var serialiser: JSONSerialiser!

    override func setUp() {
        super.setUp()
        serialiser = JSONSerialiser(decoder: JSONDecoder())
    }

    override func tearDown() {
        serialiser = nil
        super.tearDown()
    }

    func testDecodeWhenDataCannotBeDecodedThrowsDecodeError() async throws {
        let data = try XCTUnwrap("aaa".data(using: .utf8))

        do {
            _ = try await serialiser.decode(MockObject.self, from: data)
        } catch {
            XCTAssertTrue(true)
            return
        }

        XCTFail("Expected decode error to be thrown")
    }

    func testDecodeWhenDataCanBeDecodedReturnsDecodedObject() async throws {
        let expectedResult = MockObject()
        let data = expectedResult.data

        let result = try await serialiser.decode(MockObject.self, from: data)

        XCTAssertEqual(result, expectedResult)
    }

}

extension JSONSerialiserTests {

    private struct MockObject: Codable, Equatable {

        let id: UUID

        var data: Data {
            // swiftlint:disable force_try
            try! JSONEncoder().encode(self)
            // swiftlint:enable force_try
        }

        init(id: UUID = .init()) {
            self.id = id
        }
    }

}
