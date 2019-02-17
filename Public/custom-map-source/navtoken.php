<?php

function get_navtoken() {
    $memcache = new Memcache;
    $key = 'navtoken';
    $navtoken = $memcache->get($key);

    if ($navtoken == null) {
        $url = 'http://backend.navionics.io/tile/get_key/Navionics_internalpurpose_00001/webapp.navionics.com';
        $referer = 'https://webapp.navionics.com';

        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_REFERER, $referer);
        $navtoken = curl_exec($ch);
        $info = curl_getinfo($ch);
        curl_close($ch);

        if ($info["http_code"] == 200) {
            $memcache->set($key, $navtoken, 0, 3600);
        }
    }

    return $navtoken;
}
