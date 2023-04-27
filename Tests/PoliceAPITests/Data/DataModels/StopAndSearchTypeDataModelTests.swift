@testable import PoliceAPI
import XCTest

final class StopAndSearchTypeDataModelTests: XCTestCase {

    func testPersonSearch() {
        let result = StopAndSearchTypeDataModel(rawValue: "Person search")

        XCTAssertEqual(result, .personSearch)
    }

    func testVehicleSearch() {
        let result = StopAndSearchTypeDataModel(rawValue: "Vehicle search")

        XCTAssertEqual(result, .vehicleSearch)
    }

    func testPersonAndVehicleSearch() {
        let result = StopAndSearchTypeDataModel(rawValue: "Person and Vehicle search")

        XCTAssertEqual(result, .personAndVehicleSearch)
    }

    func testDescriptionWhenPersonSearchReturnDescription() {
        let expectedResult = "Person search"

        let result = StopAndSearchTypeDataModel.personSearch.rawValue

        XCTAssertEqual(result, expectedResult)
    }

    func testDescriptionWhenVehicleSearchReturnDescription() {
        let expectedResult = "Vehicle search"

        let result = StopAndSearchTypeDataModel.vehicleSearch.rawValue

        XCTAssertEqual(result, expectedResult)
    }

    func testDescriptionWhenPersonAndVehicleSearchReturnDescription() {
        let expectedResult = "Person and Vehicle search"

        let result = StopAndSearchTypeDataModel.personAndVehicleSearch.rawValue

        XCTAssertEqual(result, expectedResult)
    }

}
