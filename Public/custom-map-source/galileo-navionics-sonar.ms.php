<?php
require 'navtoken.php';
$navtoken = get_navtoken();
$mapsource = '<?xml version="1.0" encoding="UTF-8"?>
<customMapSource>
<name>Navionics SonarCharts</name>
<url>http://backend.navionics.io/tile/{$z}/{$x}/{$y}?LAYERS=config_1_6.00_1&amp;TRANSPARENT=FALSE&amp;UGC=TRUE&amp;navtoken={$navtoken}</url>
</customMapSource>';

if ($navtoken) {
    header('Content-type: application/x-galileo');
    header('Content-Disposition: attachment');
    echo str_replace('{$navtoken}', urlencode($navtoken), $mapsource);
} else {
    header('Content-type: text/plain');
    echo 'Something went wrong';
}
