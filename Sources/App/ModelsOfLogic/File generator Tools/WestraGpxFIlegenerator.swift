//
//  WestraGpxFIlegenerator.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 29.04.2020.
//  Copyright © 2020 Nnngrach. All rights reserved.
//

import Vapor
import Foundation

class WestraGpxFileGenerator {
    
    
    public func generateGpxFile(mode: String, request: Request) -> Future<Response> {
        
        let urlWithPassesJson = "https://nakarte.me/westraPasses/westra_passes.json"
        
        do {
            return try request.client()
            .get(urlWithPassesJson)
            .flatMap{ res -> Future<Response> in
                return try res.content
                    .decode([WestraPassNakarte].self)
                    .map { pointsObjects -> Response in
                        
                        let gpxContent =  self.generateGpxFromFetchedData(pointsObjects, mode)
                        
                        let headers: HTTPHeaders = ["content-disposition": "attachment; filename=\"westra_passes.gpx\""]
                        
                        let res = HTTPResponse(headers: headers, body: gpxContent)
                        
                        return Response(http: res, using: request)
                }
            }
        } catch let error {
            print(error.localizedDescription)
            return request.future(error: error)
        }
    }
    
    
    private func generateGpxFromFetchedData(_ pointsObjects: [WestraPassNakarte], _ mode: String) -> String {
        do {
            var gpxPointsContent = ""
            if mode == "locus" {
                gpxPointsContent = self.createGpxContentForLocus(using: pointsObjects)
            } else {
                gpxPointsContent = self.createGpxContentUniversal(using: pointsObjects, mode: mode)
            }
            
            let gpxFileContent = self.getFullGpxFileContent(with: gpxPointsContent)
            return gpxFileContent
        } catch let error {
            print(error)
            return error.localizedDescription
        }
    }
    
    
    private func encodeFromJson(_ data: Data) throws -> [WestraPassNakarte]{
        return try JSONDecoder().decode([WestraPassNakarte].self, from: data)
    }
    
    
    private func createGpxContentUniversal(using nakartePasses: [WestraPassNakarte], mode: String) -> String {
        var pointsBlocks = ""
        
        for point in nakartePasses {
            
            let grade = point.grade ?? "?"
            let name = point.name ?? "?"
            let elevation = point.elevation ?? "?"
            
            var additionaTags = ""
            if mode == "osmand" {
                additionaTags = getOsmandIconsTags(point.grade, point.grade_eng, point.is_summit)
            }
            
            pointsBlocks +=
            """
            <wpt lat="\(point.latlon[0])" lon="\(point.latlon[1])">
                <name>\(grade) - "\(name)" (\(elevation) m)</name>
            \(additionaTags)
            </wpt>
            
            """
        }
        
        return pointsBlocks
    }
    
    
    private func createGpxContentForLocus(using nakartePasses: [WestraPassNakarte]) -> String {
        var pointsBlocks = ""
        
        for point in nakartePasses {
            
            let name = point.name ?? "?"
            
            var altName = ""
            if let text = point.altnames {altName = " \(text)"}
            
            let gradeEn = point.grade_eng ?? ""
            let elevation = point.elevation ?? ""
            let iconName = point.is_summit == 1 ? "summit_hscc" : "rtsa_scale_\(gradeEn)_hscc"
            
            
            var description = ""
            
            let typeLabel = point.is_summit == 1 ? "Вершина" : "Перевал"
            description += "<p>\(typeLabel) \(name)\(altName)</p>"
            
            if point.grade != nil || point.elevation != nil {
                description += "<p>"
                if point.grade != nil {description += point.grade!}
                if point.grade != nil && point.elevation != nil {description += ", "}
                if point.elevation != nil {description += point.elevation! + "м."}
                description += "</p>"
            }
            
            if let connects = point.connects {
                description += "<p>Соединяет: \(connects)</p>"
            }
            
            if let slopes = point.slopes {
                description += "<p>Склоны: \(slopes)</p>"
            }
            
            if let comments = point.comments {
                description += "<p>Комментарии:<br/>"
                for comment in comments {
                    description += "\(comment.user ?? ""): "
                    description += "<cite>\(comment.content ?? "")</cite><br/>"
                }
                description += "</p>"
            }
            
            if let author = point.author {
                description += "<p>Добавил: \(author)</p>"
            }
            
            
            pointsBlocks +=
            """
            <wpt lat="\(point.latlon[0])" lon="\(point.latlon[1])">
                <name>\(name)</name>
                <ele>\(elevation)</ele>
                <link href="http://westra.ru/passes/Passes/\(point.id!)"/>
                <sym>\(iconName)</sym>
                <extensions>
                    <locus:icon>file:RTSA Scale.zip:\(iconName).png</locus:icon>
                </extensions>
                <desc><![CDATA[\(description)]]></desc>
            </wpt>
            
            """
        }
        
        return pointsBlocks
    }
    
    
    
    private func getFullGpxFileContent(with pointsContent: String) -> String {
        return """
        <?xml version="1.0" encoding="utf-8" standalone="yes"?>
        <gpx version="1.1"
        xmlns="http://www.topografix.com/GPX/1/1"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
        xmlns:gpx_style="http://www.topografix.com/GPX/gpx_style/0/2"
        xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3"
        xmlns:gpxtrkx="http://www.garmin.com/xmlschemas/TrackStatsExtension/v1"
        xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v2">
        \(pointsContent)
        </gpx>
        """
    }
    
    
    
    private func getOsmandIconsTags(_ pointGrade: String?, _ pointGrade_eng: String?, _ isSummit: Int?) -> String {
        
        let tagsForUnknownPoins = """
            <extensions>
                <icon>natural_saddle</icon>
                <background>square</background>
                <color>#727272</color>
            </extensions>
        """
        
        guard let grade = pointGrade else {return tagsForUnknownPoins}
        guard let grade_en = pointGrade_eng else {return tagsForUnknownPoins}
        
        var iconTags = ""
        
        if grade.contains("?") || grade_en == "" {
            iconTags = """
                    <icon>natural_saddle</icon>
                    <background>square</background>
                    <color>#727272</color>
            """
        } else if grade.contains("н") || grade_en == "nograde" {
            iconTags = """
                    <icon>special_number_0</icon>
                    <background>square</background>
                    <color>#727272</color>
            """
        } else if grade.contains("1А") || grade_en == "1a" {
            iconTags = """
                    <icon>special_number_1</icon>
                    <background>square</background>
                    <color>#38ccd4</color>
            """
        } else if grade.contains("1Б") || grade_en == "1b" {
            iconTags = """
                    <icon>special_number_1</icon>
                    <background>square</background>
                    <color>#536CFE</color>
            """
        } else if grade.contains("2А") || grade_en == "2a" {
            iconTags = """
                    <icon>special_number_2</icon>
                    <background>square</background>
                    <color>#52a262</color>
            """
        } else if grade.contains("2Б") || grade_en == "2b" {
            iconTags = """
                    <icon>special_number_2</icon>
                    <background>square</background>
                    <color>#23572e</color>
            """
        } else if grade.contains("3А") || grade_en == "3a" {
            iconTags = """
                    <icon>special_number_3</icon>
                    <background>square</background>
                    <color>#e68200</color>
            """
        } else if grade.contains("3Б") || grade_en == "3b" {
            iconTags = """
                    <icon>special_number_3</icon>
                    <background>square</background>
                    <color>#b24729</color>
            """
        } else if isSummit != nil  &&  isSummit! == 1 {
            iconTags = """
                    <icon>natural_peak_big</icon>
                    <color>#804800</color>
                    <background>square</background>
            """
        } else {
            return""
        }
        
        
        return
        """
            <extensions>
        \(iconTags)
            </extensions>
        """
    }
    
}
