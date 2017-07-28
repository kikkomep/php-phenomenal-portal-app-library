<?php

ini_set('display_errors', 1);
error_reporting(E_ALL ^ E_NOTICE);

include('service.php');

switch($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        $term = isset($_GET['term']) ? $_GET['term'] : '';
        searchPageContent($term);
        break;
    default:
        print_r(json_encode(createEmptyJSONDataArray()));
}

function listFiles($file_name, $format){

    // No ../ are allowed and something has to be requested
    if(  (strpos($file_name, '../') !== false || $file_name == '') ) {
        getAllWiki();
    } else {
        getContentFromWiki($file_name, $format);
    }

}

?>
