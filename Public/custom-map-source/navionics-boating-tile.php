<?php
require 'navtoken.php';
$navtoken = get_navtoken();
$url = 'http://backend.navionics.io/tile/{$z}/{$x}/{$y}?LAYERS=config_1_6.00_0&TRANSPARENT=FALSE&UGC=TRUE&navtoken={$navtoken}';
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
list ($root, $script, $z, $x, $y) = explode('/', $path);
$url = str_replace(array('{$z}', '{$x}', '{$y}', '{$navtoken}'), array($z, $x, $y, urlencode($navtoken)), $url);
header('Location: '. $url);
