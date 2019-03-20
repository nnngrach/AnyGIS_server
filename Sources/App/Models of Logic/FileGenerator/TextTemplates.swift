//
//  TextTemplates.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 24/02/2019.
//

import Foundation

struct TextTemplates {
    
    //MARK: Links
    
    let localPathToMarkdownPages = "file:////Projects/GIS/Online%20map%20sources/map-sources/Web/Html/Download/"
    
    let localPathToIcons = "file:////Projects/GIS/Online%20map%20sources/map-sources/Locus_online_maps/Icons/"
    let localPathToInstallers = "file:////Projects/GIS/Online%20map%20sources/map-sources/Locus_online_maps/Installers/"
    let localPathToLocusMapsFull = "file:////Projects/GIS/Online%20map%20sources/map-sources/Locus_online_maps/Maps_full/"
    let localPathToLocusMapsShort = "file:////Projects/GIS/Online%20map%20sources/map-sources/Locus_online_maps/Maps_short/"
    let localPathToGuruMapsFull = "file:////Projects/GIS/Online%20map%20sources/map-sources/Galileo_online_maps/Maps_full/"
    let localPathToGuruMapsShort = "file:////Projects/GIS/Online%20map%20sources/map-sources/Galileo_online_maps/Maps_short/"
    
    
    let localPathToGuruMapsInServer = "file://///Projects/GIS/AnyGIS%20server/AnyGIS_Server/Public/galileo/"
    let localPathToOruxMapsFullInServer = "file:////Projects/GIS/AnyGIS%20server/AnyGIS_Server/Public/orux_full/"
    let localPathToOruxMapsShortInServer = "file:////Projects/GIS/AnyGIS%20server/AnyGIS_Server/Public/orux_short/"
    
    let gitLocusInstallersFolder = "https://github.com/nnngrach/AnyGIS_maps/master/Locus_online_maps/Installers/"
    let gitLocusIconsFolder = "https://github.com/nnngrach/AnyGIS_maps/raw/master/Locus_online_maps/Icons/"
    let gitLocusPagesFolder = "https://raw.githubusercontent.com/nnngrach/AnyGIS_maps/master/Web/Html/Download/"
    
    let gitLocusMapsFolder = "https://raw.githubusercontent.com/nnngrach/AnyGIS_maps/master/Locus_online_maps/Maps_full/"
    let anygisGuruMapsFolder = "https://anygis.herokuapp.com/download/galileo/"
    
    
    let gitLocusFullMapsZip = "https://minhaskamal.github.io/DownGit/#/home?url=https://github.com/nnngrach/AnyGIS_maps/tree/master/Locus_online_maps/Maps_full"
    let gitLocusShortMapsZip = "https://minhaskamal.github.io/DownGit/#/home?url=https://github.com/nnngrach/AnyGIS_maps/tree/master/Locus_online_maps/Maps_short"
    
    let gitLocusActionInstallersFolder = "locus-actions://https/raw.githubusercontent.com/nnngrach/AnyGIS_maps/master/Locus_online_maps/Installers/"
    let gitGuruActionInstallersFolder = "guru://open?path=https://raw.githubusercontent.com/nnngrach/AnyGIS_maps/master/Galileo_online_maps/Maps_full/"
    
    
    
    
    let indexPage = "https://nnngrach.github.io/AnyGIS_maps/index"
    let descriptionPage = "https://nnngrach.github.io/AnyGIS_maps/Web/Html/Description"
    let rusOutdoorPage = "https://nnngrach.github.io/AnyGIS_maps/Web/Html/RusOutdoor"
    let downloadPage = "https://nnngrach.github.io/AnyGIS_maps/Web/Html/DownloadPage"
    let locusPage = "https://nnngrach.github.io/AnyGIS_maps/Web/Html/Locus"
    let guruPage = "https://nnngrach.github.io/AnyGIS_maps/Web/Html/Galileo"
    let oruxPage = "https://nnngrach.github.io/AnyGIS_maps/Web/Html/Orux"
    let osmandPage = "https://nnngrach.github.io/AnyGIS_maps/Web/Html/Osmand"
    let apiPage = "https://nnngrach.github.io/AnyGIS_maps/Web/Html/Api"
    
    let anygisMapUrl = "https://anygis.herokuapp.com/{mapName}/{x}/{y}/{z}"
    
    let email = "anygis@bk.ru"

    
 
    
    
    //MARK: Templates for description
    
    func getCreationTime() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter.string(from: currentDate)
    }
    
    
    
    func getDescription(appName: ClientAppList) -> String {
        
        var currentAppPageUrl: String
        
        switch appName {
        case .GuruMapsIOS, .GuruMapsAndroid:
            currentAppPageUrl = guruPage
        case .Locus:
            currentAppPageUrl = locusPage
        case .Osmand:
            currentAppPageUrl = osmandPage
        case .Orux:
            currentAppPageUrl = oruxPage
        }
        
        let currentAppName = appName.rawValue
        
        
        let nameString = """
        Комплект карт "AnyGIS" для навигатора \(currentAppName).
        \(currentAppPageUrl)
        """
        
        
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
        
        \(getDescription(appName: .Locus))
        
        
        <locusActions>
        
        """
    }
    
    
    
    func getLocusActionsItem(fileName: String, isIcon: Bool) -> String {
        
        let patch = isIcon ? gitLocusIconsFolder : gitLocusMapsFolder
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
        | [AnyGIS][01] | [Как это работает?][02] | [RusOutdoor Maps][03] | [Скачать карты][04] | [API][05] |
        
        
        [01]: \(indexPage)
        [02]: \(descriptionPage)
        [03]: \(rusOutdoorPage)
        [04]: \(downloadPage)
        [05]: \(apiPage)

        """
    }
    
    
    
    func getMarkdownMaplistIntro(appName: ClientAppList) -> String {
        
        let name = appName.rawValue
        
        return """
        # Скачать карты для \(name)
        
        """
    }
    
    
    
    func getMarkdownMaplistCategory(appName: ClientAppList, categoryName: String, fileName: String) -> String {
        let locusFolderDownloaderUrl = gitLocusActionInstallersFolder + "_" + fileName.cleanSpaces() + ".xml"
        
        var resultText = ""
        
        switch appName {
        case .Locus:
            resultText = """
            
            
            ### [\(categoryName)](\(locusFolderDownloaderUrl) "Скачать всю группу")
            
            """
            
        default:
            resultText = """
            
            
            ### \(categoryName)
            
            """
        }
        
        return resultText
    }
    
    
    
    func getMarkDownMaplistItem(appName: ClientAppList, name:String, fileName: String) -> String {

        var resultUrl = ""
        
        switch appName {
        case .Locus:
            resultUrl = gitLocusActionInstallersFolder + "__" + fileName + ".xml"
        case .GuruMapsIOS:
            resultUrl = gitGuruActionInstallersFolder + fileName + ".ms"
        case .GuruMapsAndroid:
            resultUrl = anygisGuruMapsFolder + fileName + ".ms"
        default:
            break
        }
         
        return """
        [\(name)](\(resultUrl) "Скачать эту карту")
        
        
        """
    }
    
    
    
    
    
    
    
    
    //MARK: Templates for Locus maps XLM
    
    func getLocusMapIntro(comment: String) -> String {
        
        var secondDescription = ""
        
        if comment.replacingOccurrences(of: " ", with: "") != "" {
            secondDescription = """
            <!--
            \(comment)
            -->
            
            """
        }
        
        
        return """
        <?xml version="1.0" encoding="utf-8"?>
        
        \(getDescription(appName: .Locus))
        
        \(secondDescription)
        
        <providers>
        
        """
    }
    
    
    
    
    func getLocusMapItem(id: Int, projection: Int, visible: Bool, background: String, group: String, name: String, countries: String, usage: String, url: String, serverParts: String, zoomMin: Int, zoomMax: Int, referer: String) -> String {
        
        var result = """

        <provider id="\(id)" type="\(projection)" visible="\(visible)" background="\(background)">
            <name>\(group)</name>
            <mode>\(name)</mode>
            <countries>\(countries)</countries>
            <usage>\(usage)</usage>
            <url><![CDATA[\(url)]]></url>
        
        """
        
        
        if serverParts != "" || serverParts != " " {
            result += """
                <serverPart>\(serverParts)</serverPart>
            
            """
        }
        
        
        result += """
            <zoomPart>{z}-8</zoomPart>
            <zoomMin>\(zoomMin + 8)</zoomMin>    <!-- \(zoomMin) -->
            <zoomMax>\(zoomMax + 8)</zoomMax>   <!-- \(zoomMax) -->
            <tileSize>256</tileSize>
        
        """
        
        
        if referer.replacingOccurrences(of: " ", with: "") != "" {
            result += """
                <extraHeader><![CDATA[Referer#\(referer)]]></extraHeader>
            
            """
        }

        
        result += """
            <extraHeader><![CDATA[User-Agent#Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.110 Safari/537.36]]></extraHeader>
            <attribution><![CDATA[Сборник карт AnyGIS. <a href="\(locusPage)">Проверить обновления</a>]]></attribution>
        </provider>
        
        """
        
        return result
    }
    
    
    
    
    func getLocusMapOutro() -> String {
        return """
        
        </providers>
        """
    }
    
    
    
    
    
    
    //MARK: Templates for GuruMaps (Galileo) maps MS
    
    func getGuruMapIntro(mapName: String, comment: String) -> String {
        
        var secondDescription = ""
        
        if comment.replacingOccurrences(of: " ", with: "") != "" {
            secondDescription = """
            <!--
            \(comment)
            -->
            
            """
        }
        
        
        return """
        <?xml version="1.0" encoding="utf-8"?>
                
        <customMapSource>
        <name>\(mapName)</name>
        <layers>

        
        """
    }
    
    
    
    func getGuruMapsItem(url: String, zoomMin: Int, zoomMax: Int, serverParts: String) -> String {
        
        let firtstPart = """
            <layer>
            <minZoom>\(zoomMin)</minZoom>
            <maxZoom>\(zoomMax)</maxZoom>
            <url>\(url)</url>

        """
        
        var secondPart = ""
        
        if serverParts.replacingOccurrences(of: " ", with: "") != "" {
            secondPart = """
                <serverParts>\(serverParts)</serverParts>
            
            """
        }
        
        let thirdPart = """
            </layer>


        """
        
        return firtstPart + secondPart + thirdPart
    }
    
    
    
    func getGuruMapOutro() -> String {
        return """
        
        </layers>
        </customMapSource>
        """
    }
    
    
    
    
    
    //MARK: Templates for Orux maps XML
    
    func getOruxMapIntro() -> String {
        return """
        <?xml version="1.0" encoding="utf-8"?>
        <onlinemapsources>
        
        """
    }
    
    
    func getOruxMapsItem(id: Int, projectionName: String, name: String, group: String, url: String, serverParts: String, zoomMin: Int, zoomMax: Int, cacheable: Int, yInvertingScript: String) -> String {

        
        return """
        
            <onlinemapsource uid="\(id)">
                <name>\(name) (\(group))</name>
                <url><![CDATA[\(url)]]></url>
                <servers>\(serverParts)</servers>
                <maxzoom>\(zoomMax)</maxzoom>
                <minzoom>\(zoomMin)</minzoom>
                <projection>\(projectionName)</projection>
                <downloadable>1</downloadable>
                <cacheable>\(cacheable)</cacheable>
                <xop></xop>
                <yop>\(yInvertingScript)</yop>
                <zop></zop>
                <qop></qop>
            </onlinemapsource>
        
        """
    }
    
    
    func getOutroMapOutro() -> String {
        return """
        
        
        </onlinemapsources>
        """
    }
}
