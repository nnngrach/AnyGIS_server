<?xml version="1.0" encoding="UTF-8"?>
<customMapSource>
<name>Eniro + Navionics Boating</name>
<layers>
<layer>
<url>http://{$serverpart}.eniro.no/geowebcache/service/tms1.0.0/map2x/{$z}/{$x}/{$invY}.png</url>
<serverParts>map01 map02 map03 map04</serverParts>
</layer>
<layer>
<url>http://backend.navionics.io/tile/{$z}/{$x}/{$y}?LAYERS=config_1_6.00_0&amp;TRANSPARENT=TRUE&amp;UGC=TRUE&amp;navtoken=TmF2aW9uaWNzX2ludGVybmFscHVycG9zZV8wMDAwMSt3ZWJhcHAubmF2aW9uaWNzLmNvbSsxdjViY25wY2lrOQ%3D%3D</url>
</layer>
</layers>
</customMapSource>