<?php

$filename = 'galileo-google-maps.ms';

header("Content-type: application/x-download");
header("Content-Disposition: attachment; filename=$filename");
readfile($filename);

?>