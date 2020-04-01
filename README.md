# AnyGIS Server

This is a server utility, which helping to connect different navigation applications (web, ios, android) to different online-map sources.

It receives a GET request from the client navigation apps to download a tile. Next it gets the map name and XYZ coordinates parameters from this query. Depending on the specified of this map, AnyGIS generates a corresponding URL. Then it downloads a tile and returns it to the client app.

This proxi component can perform various additional calculations and can generate quite complex and dynamically changing non-standard URL addresses. This allows you to connect many of the previously unavailable maps to mobile navigation apps.

Also, this utility is able to do various image processing on the fly. For example, it can transform tiles from the WGS84 ellipsoid projection to the WebMerkatror spherical projection. Or overlay one image on another if the client application does not allow such operations.

You can read more about how this utility works on [this page](https://nnngrach.github.io/AnyGIS_maps/Web/Html/Description).



# AnyGIS Server API

### Get tile by tile numbers

You can load tiles by sending GET request with these parameters:

```
Host / MapName / xTileNumber / yTileNumber / zoomLevel
```

You can use standard WebMercator tile numbers. Just like numbers from OpenStreetMaps or Google maps.


For example let's load a tile of Wikimapia.org map:

```
Host = https://anygis.ru/api/v1/
MapName = Wikimapia
X = 619
Y = 320
Z = 10
```

Result URL to load this tile will be looking like this:

[https://anygis.ru/api/v1/Wikimapia/619/320/10](https://anygis.ru/api/v1/Wikimapia/619/320/10)



### Get tile by tile coordinates

You can also find tiles by its coordinates in decimal format:

```
Host / MapName / Longitude / Latitude / Z
```
[https://anygis.ru/api/v1/Wikimapia/56.062293/37.708244/10](https://anygis.ru/api/v1/Wikimapia/56.062293/37.708244/10)



### Get maps list

To get MapName parameter you have to open a list of available maps.

[https://anygis.ru/Web/Html/Download_en?app=Desktop](https://anygis.ru/Web/Html/Download_en?app=Desktop)

Found there a map which you wish to load. Click on it. In the window that opens, find the "[URL via AnyGIS proxy]" field. You will find MapName parameter in it.


```
[Name]
Info - Wikimapia.org

[URL via AnyGIS proxy]
https://anygis.ru/api/v1/Wikimapia/{x}/{y}/{z}
```

