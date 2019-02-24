//
//  TextTemplates.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 24/02/2019.
//

import Foundation

struct TextTemplates {
    
    //MARK: Links
    
    let pathToIcons = "file:////Projects/GIS/Online%20map%20sources/map-sources/Locus_online_maps/script/Icons/"
    let pathToInstallers = "file:////Projects/GIS/Online%20map%20sources/map-sources/Locus_online_maps/script/Installers/"
    let pathToMarkdownMaps = "file:////Projects/GIS/Online%20map%20sources/map-sources/Locus_online_maps/script/Maps/"
    let pathToMarkdownPages = "file:////Projects/GIS/Online%20map%20sources/map-sources/Locus_online_maps/script/Pages/"
    
    let locusInstallersFolder = "https://github.com/nnngrach/map-sources/raw/PreparingForFilegeneraor/Locus_online_maps/script/Installers/"
    let locusPagesFolder = "https://raw.githubusercontent.com/nnngrach/map-sources/PreparingForFilegeneraor/Locus_online_maps/script/Pages/"
    
    
    //let locusInstallersFolder = "https://github.com/nnngrach/map-sources/raw/master/Locus_online_maps/script/Installers/"
    let locusIconsFolder = "https://github.com/nnngrach/map-sources/raw/master/Locus_online_maps/script/Icons/"
    let locusMapsFolder = "https://raw.githubusercontent.com/nnngrach/map-sources/master/Locus_online_maps/Full_set/"
    //let locusPagesFolder = "https://raw.githubusercontent.com/nnngrach/map-sources/master/Locus_online_maps/script/Pages/"
    
    let indexPage = "https://nnngrach.github.io/map-sources/index"
    let descriptionPage = "https://nnngrach.github.io/map-sources/Web/Html/Description"
    let rusOutdoorPage = "https://nnngrach.github.io/map-sources/Web/Html/RusOutdoor"
    let locusPage = "https://nnngrach.github.io/map-sources/Web/Html/Locus"
    let guruPage = "https://nnngrach.github.io/map-sources/Web/Html/Galileo"
    let apiPage = "https://nnngrach.github.io/map-sources/Web/Html/Api"
    
    let email = "anygis@bk.ru"

    
 
    
    
    //MARK: Templates for description
    
    func getCreationTime() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter.string(from: currentDate)
    }
    
    
    func getDescription(forLocus: Bool) -> String {
        
        let locusName = """
        Комплект карт "AnyGIS" для навигатора Locus.
        \(locusPage)
        """
        
        let guruName = """
        Комплект карт "AnyGIS" для навигатора GuruMaps (ex Galileo)
        \(guruPage)
        """
        
        let nameString = forLocus ? locusName : guruName
        
        
        return """
        <!--
        \(nameString)
        
        Составитель: AnyGIS (\(email)).
        Файл обновлен: \(getCreationTime())
        
        Сделан на основе наборов карт от:
        - SAS.planet (http://www.sasgis.org/)
        - Erelen (https://melda.ru/locus/)
        - ms.Galileo-app (https://ms.galileo-app.com/)
        - Custom-maps-sourse (https://custom-map-source.appspot.com/)
        -->
        """
    }
    
    
    
    
    
    //MARK: Templates for Locus actions XLM installer
    
    func getLocusActionsIntro() -> String {
        return """
        <?xml version="1.0" encoding="utf-8"?>
        
        \(getDescription(forLocus: true))
        
        
        <locusActions>
        
        """
    }
    
    
    func getLocusActionsItem(fileName: String, isIcon: Bool) -> String {
        
        let patch = isIcon ? locusIconsFolder : locusInstallersFolder
        let fileType = isIcon ? ".png" : ".xml"
        let filenameWithoutSpaces = fileName.makeCorrectPatch()
        
        
        return """
        
            <download>
                <source>
                <![CDATA[\(patch + filenameWithoutSpaces + fileType)]]>
                </source>
                <dest>
                <![CDATA[/mapsOnline/custom/\(fileName + fileType)]]>
                </dest>
            </download>
        
        """
    }
    
    
    func getLocusActionsOutro() -> String {
        return """
        
        </locusActions>
        """
    }
    
    
    
    
    
    //MARK: Templates for Markdown page generation
    
    func getMarkdownHeader() -> String {
        return """
        | [AnyGIS][01] | [Как это работает?][02] | [RusOutdoor Maps][03] | [Карты для Locus][04] | [Карты для GuruMaps][05] | [API][06] |
        
        
        [01]: \(indexPage)
        [02]: \(descriptionPage)
        [03]: \(rusOutdoorPage)
        [04]: \(locusPage)
        [05]: \(guruPage)
        [06]: \(apiPage)

        """
    }
    
    
    func getMarkdownMaplistIntro() -> String {
        return """
        # Скачать карты для Locus
        
        """
    }
    
    
    func getMarkdownMaplistCategory(categoryName: String) -> String {
        let url = locusInstallersFolder + "_" + categoryName.makeCorrectPatch() + ".xml"
        
        return """
        ### [\(categoryName)](\(url) "Скачать всю группу")
        
        """
    }
    
    
    func getMarkDownMaplistItem(mapName: String) -> String {
        let url = locusInstallersFolder + "__" + mapName + ".xml"
        
        return """
        [\(mapName)](\(url) "Скачать эту карту")
        
        """
    }

    
}
