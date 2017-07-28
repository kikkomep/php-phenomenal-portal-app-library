<?php

ini_set('display_errors', 1);
error_reporting(E_ALL ^ E_NOTICE);

include('service.php');

switch($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        $folder_name = isset($_GET['foldername']) ? $_GET['foldername'] : '';
        $file_name = isset($_GET['filename']) ? $_GET['filename'] : '';
        $format = isset($_GET['format']) ? $_GET['format'] : '';
        $limit = isset($_GET['limit']) ? $_GET['limit'] : '';
        parseMenuPageContent($folder_name, $file_name, $format, $limit);
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
