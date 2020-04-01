import XCTest
@testable import App


final class CoordinateTransformerTests: XCTestCase {
    
    var sut: CoordinateTransformer!
    
    override func setUp() {
        super.setUp()
        sut = CoordinateTransformer()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    

    
    func testTileNumersShouldBeConvertedToLatLon() {
        // given
        let expectedValue = (lat_deg: 55.97379820507658, lon_deg: 37.265625)
        // when
        let resultValue = sut.tileNumberToCoordinates(618, 319, 10)
        // then
        XCTAssertEqual(expectedValue.lat_deg, resultValue.lat_deg)
        XCTAssertEqual(expectedValue.lon_deg, resultValue.lon_deg)
    }
    
    
    func testLatLonShouldBeConvertedToTileNumbers() {
        // given
        let expectedValue = (x: 618, y: 319, z: 10)
        // when
        let resultValue = sut.coordinatesToTileNumbers(55.97379820507658, 37.265625, withZoom: 10)
        // then
        XCTAssertEqual(expectedValue.x, resultValue.x)
        XCTAssertEqual(expectedValue.y, resultValue.y)
        XCTAssertEqual(expectedValue.z, resultValue.z)
    }
    
    
    
    func testLatLonShouldBeConvertedToEllipsoidTileNumbers() {
        // given
        let expectedValue = (x: 618, y: 319, offsetX: 0, offsetY: 231)
        // when
        let resultValue = sut.getWGS84Position(55.97379820507658, 37.265625, withZoom: 10)
        // then
        XCTAssertEqual(expectedValue.x, resultValue.x)
        XCTAssertEqual(expectedValue.y, resultValue.y)
        XCTAssertEqual(expectedValue.offsetX, resultValue.offsetX)
        XCTAssertEqual(expectedValue.offsetY, resultValue.offsetY)
    }
    
    
    
    func testTileNumbestShouldBeConvertedQuadkeyTileNumber() {
        // given
        let expectedValue = "1201323232"
        // when
        let resultValue = sut.tileNumberToQuad(618, 319, 10)
        // then
        XCTAssertEqual(expectedValue, resultValue)
    }
    
}
