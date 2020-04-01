import XCTest
@testable import App


class URLPatchCreatorTests: XCTestCase {
    
    var sut: URLPatchCreator!
    
    let defaultMapDTO = MapsList(name: "", mode: "", backgroundUrl: "", backgroundServerName: "", referer: "", zoomMin: 0, zoomMax: 18, dpiSD: "", dpiHD: "", parameters: 0, description: "")

    override func setUp() {
        super.setUp()
        sut = URLPatchCreator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    
    
    
    func testShouldWriteRegularTileNumbers() {
        // given
        let regularTileNumbers = "618/319/10"
        // when
        let testingMapDTO = defaultMapDTO
        testingMapDTO.backgroundUrl = "{x}/{y}/{z}"
        let resultValue = sut.calculateTileURL(618, 319, 10, testingMapDTO)
        // then
        XCTAssertEqual(resultValue, regularTileNumbers)
    }
    
    
    func testShouldWriteEllipsoidTileNumbers() {
        // given
        let ellipsodTileNumbers = "77578/30403"
        // when
        let testingMapDTO = defaultMapDTO
        testingMapDTO.backgroundUrl = "{yandexX}/{yandexY}"
        let resultValue = sut.calculateTileURL(77578, 30403, 17, testingMapDTO)
        // then
        XCTAssertEqual(resultValue, ellipsodTileNumbers)
    }

    
    func testShouldWriteQuadkeyTileNumber() {
        // given
        let quadkeyTileNum = "1201323232"
        // when
        let testingMapDTO = defaultMapDTO
        testingMapDTO.backgroundUrl = "{q}"
        let resultValue = sut.calculateTileURL(618, 319, 10, testingMapDTO)
        // then
        XCTAssertEqual(resultValue, quadkeyTileNum)
    }
    
    
    
    func testShouldWriteBbox() {
        // given
        let bboxCoordinates = "4148390.399093084,7514065.628545966,4187526.157575097,7553201.387027975"
        // when
        let testingMapDTO = defaultMapDTO
        testingMapDTO.backgroundUrl = "{bbox}"
        let resultValue = sut.calculateTileURL(618, 319, 10, testingMapDTO)
        // then
        XCTAssertEqual(resultValue, bboxCoordinates)
    }
    
    
    
    func testShouldWriteInvertedY() {
        // given
        let invertedY = "704"
        // when
        let testingMapDTO = defaultMapDTO
        testingMapDTO.backgroundUrl = "{-y}"
        let resultValue = sut.calculateTileURL(618, 319, 10, testingMapDTO)
        // then
        XCTAssertEqual(resultValue, invertedY)
    }
    
    
    
    func testShouldWriteSasPlanetParameters() {
        // given
        let sasPlanetParams = "15/9/4"
        // when
        let testingMapDTO = defaultMapDTO
        testingMapDTO.backgroundUrl = "{z+1}/{x/1024}/{y/1024}"
        let resultValue = sut.calculateTileURL(9907, 5093, 14, testingMapDTO)
        // then
        XCTAssertEqual(resultValue, sasPlanetParams)
    }
    
    
    
    func testShouldWriteRandomServerNameChar() {
        // given
        let randomServerName = "a"
        // when
        let testingMapDTO = defaultMapDTO
        testingMapDTO.backgroundUrl = "{s}"
        testingMapDTO.backgroundServerName = "a;a;a"
        let resultValue = sut.calculateTileURL(618, 319, 10, testingMapDTO)
        // then
        XCTAssertEqual(resultValue, randomServerName)
    }
    
    
    func testShouldWriteWikimapiaServerNameNumber() {
        // given
        let serverName = "14"
        // when
        let testingMapDTO = defaultMapDTO
        testingMapDTO.backgroundUrl = "{s}"
        testingMapDTO.backgroundServerName = "wikimapia"
        let resultValue = sut.calculateTileURL(618, 319, 10, testingMapDTO)
        // then
        XCTAssertEqual(resultValue, serverName)
    }

}
