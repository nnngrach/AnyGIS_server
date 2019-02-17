<?php
require 'navtoken.php';
$navtoken = get_navtoken();
$mapsource = '<?xml version="1.0" encoding="UTF-8"?>
<customMapSource>
<name>Eniro + Navionics Boating</name>
<layers>
<layer>
<url>http://{$serverpart}.eniro.no/geowebcache/service/tms1.0.0/map2x/{$z}/{$x}/{$invY}.png</url>
<serverParts>map01 map02 map03 map04</serverParts>
</layer>
<layer>
<url>http://backend.navionics.io/tile/{$z}/{$x}/{$y}?LAYERS=config_1_6.00_0&amp;TRANSPARENT=TRUE&amp;UGC=TRUE&amp;navtoken={$navtoken}</url>
</layer>
</layers>
</customMapSource>';

if ($navtoken) {
    header('Content-type: application/x-galileo');
    header('Content-Disposition: attachment');
    echo str_replace('{$navtoken}', urlencode($navtoken), $mapsource);
} else {
    header('Content-type: text/plain');
    echo 'Something went wrong';
}
