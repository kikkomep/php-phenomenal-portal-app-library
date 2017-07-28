<?php
require('simple_html_dom.php');
require_once('../lib/search/loader.php');
ini_set('display_errors', 1);
error_reporting(E_ALL ^ E_NOTICE);
set_time_limit(60);

$path = "../wiki-html";

function getAllWiki(){
    global $path;

    $dir = $path;

    getFilenames($dir, '');
}

function searchPageContent($term){
    $result = array();

    if($term == '') {
        $result['result'] = 0;
        $result['data'] = array();
    } else {
        global $path;
        $dir = $path."/phenomenal-h2020.wiki/";
        $result['result'] = 1;

        $temp = array();
        $temp = getFilenamesList($dir);
        $searchResult = array();

         foreach ($temp as $k=>$v){

             if(stripos($v['name'], $term) !== false){
                $searchResult[] = $v;
             }
         }

         try {
            $docsearch = new File_Search\Document_Search(
                array(__DIR__ . '/../wiki-html/phenomenal-h2020.wiki/'),
                $term
            );
        } catch(Exception $e) {
            echo $e->getMessage();
        }

        if(isset($docsearch) && $docsearch != NULL) {
//            var_dump($docsearch->getContainingFiles());
            foreach ($docsearch->getContainingFiles() as $value){
//                 echo pathinfo($value)['filename'];
                 foreach ($temp as $k=>$v){
                     if(strcmp($v['link'], pathinfo($value)['filename']) == 0){
                        $searchResult[] = $v;
                     }
                 }
            }

        }


//        echo var_dump($searchResult);
        $searchResult = array_unique($searchResult, SORT_REGULAR);
//        echo var_dump($searchResult);

        $result['data'] = array_values($searchResult);
    }
    echo json_encode($result);
}

function getFilenamesList($dir) {
    $data = createEmptyJSONDataArray();
    $data = parseMenuForSearch($dir.'Tutorials');

    $data = array_merge(parseMenuForSearch($dir.'Tutorials'), parseMenuForSearch($dir.'User-Documentation'), parseMenuForSearch($dir.'Developer-Documentation'));

    return $data;
}

function parseMenuForSearch($dir){

    $data = array();

    $html = file_get_html($dir);

    foreach($html->find('li') as $row) {

        if(!is_null($row->find('a', 0)->href)) {
            $temp = array();
            $temp['link'] = $row->find('a', 0)->href;
            $temp['name'] = $row->plaintext;
            $data[] = $temp;
        }
    }
    return $data;
}


function parseMenuPageContent($folderName, $file_name, $format, $limit){

    global $path;

    $dir = $path."/".$folderName."/".$file_name;
    parseMenuPage($dir, $format, $limit);
}

function parseMenuPage($dir, $format, $limit){

    $result = array();

    if( strpos($dir, '../') == true || $dir == '' ) {
        $result['result'] = 0;
        $result['data'] = '{}';

    } else {

        $result['result'] = 1;

        $data = array();

        $html = file_get_html($dir);

        foreach($html->find('li') as $row) {

            if($limit > 0 || $limit == -1){
                $temp = array();

                $temp['link'] = $row->find('a', 0)->href;
                $temp['name'] = $row->plaintext;

                $data[] = $temp;
                $limit--;
            }

        }
        $result['data'] = $data;
    }

    echo json_encode($result);
}

function parsePageContent($folderName, $file_name, $format, $limit){

    global $path;

    $dir = $path."/".$folderName."/".$file_name;
    parsePage($dir, $format, $limit);
}

function parsePage($dir, $format, $limit){

    $result = array();

    if( !file_exists($dir) || strpos($dir, '../') == true || $dir == '' ) {
        $result['result'] = 0;
        $result['data'] = 'TBD';

    } else {

        $result['result'] = 1;

        $data = array();

        $html = file_get_contents($dir);

        $html = mb_convert_encoding($html, 'HTML-ENTITIES', "UTF-8");;

//        $html = file_get_html($dir);
//        foreach($html->find('li') as $row) {
//
//            if($limit > 0 || $limit == -1){
//                $temp = array();
//
//                $temp['link'] = $row->find('a', 0)->href;
//                $temp['name'] = $row->plaintext;
//
//                $data[] = $temp;
//                $limit--;
//            }
//
//        }
     //   header('Content-Type: application/json');
 //       echo $html;
       // $result['data'] = htmlentities($html, ENT_QUOTES | ENT_IGNORE, "UTF-8");

        $result['data'] = $html;
    }

    echo json_encode($result);
}


function getContentFromWiki($folderName, $format){

    global $path;

    $dir = $path."/".$folderName;

    getFilenames($dir, $format);
}

function getFilenames($dir, $format){

    $data = createEmptyJSONDataArray();

    if($format !== 'array'){
        if(is_dir($dir)){
            $indir = array_filter(scandir($dir), function($item) {
                return $item[0] !== '.';
            });

            $data['result'] = 1;
            $data['data'] = $indir;
        }
    } else {
        if(is_dir($dir)){
            $indir = array_filter(scandir($dir), function($item) {
                return $item[0] !== '.';
            });

            $data['result'] = 1;
            $data['data'] = array_values($indir);
        }

    }


    print_r(json_encode($data));
}

function createEmptyJSONDataArray(){
    $data = array();

    $data['result'] = 0;
    $data['data'] = json_decode ("{}");

    return $data;
}

?>
