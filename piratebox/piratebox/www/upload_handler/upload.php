<?php
/* Configuration of PirateBox */
require_once('../piratebox_config.php');
?>

<?php
function mb_basename($path) {
    if (preg_match('@^.*[\\\\/]([^\\\\/]+)$@s', $path, $matches)) {
        return $matches[1];
    } else if (preg_match('@^([^\\\\/]+)$@s', $path, $matches)) {
        return $matches[1];
    }
    return '';
}
function load_template($name){
    /* Load custom template, if available - if not, load default */

    if ( file_exists('../content/php_templates/'. $name ) ){
        require_once('../content/php_templates/'. $name );
    } else {
        require_once('../default/'.$name);
    }
}
?>

<?PHP
load_template('tpl_upload.php');
template_upload_start();
$message="";
try {
    // Pre checks to verify upload configuration
    if ( $config['upload_enabled'] == 'no' )
        throw new RuntimeException('upload disabled') ;

    if ( ! file_exists($config['upload_folder']) )
       throw new RuntimeException('Upload folder "'.$config['upload_folder'].'" not available');

    if ( ! is_writable($config['upload_folder']) )
        throw new RuntimeException('Upload folder "'.$config['upload_folder'].'" not writable');

    if ( ! file_exists(ini_get('upload_tmp_dir')) )
        throw new RuntimeException('tmp folder "'.ini_get('upload_tmp_dir').'" not available');

    if ( ! is_writable(ini_get('upload_tmp_dir')) )
        throw new RuntimeException('tmp folder "'.ini_get('upload_tmp_dir').'" not writable');


    // Undefined | Multiple Files | $_FILES Corruption Attack
    // If this request falls under any of them, treat it invalid.
    if ( !  (
        !isset($_FILES['uploaded_file']['error']) ||
        is_array($_FILES['uploaded_file']['error'])
    ) ) {
        // Check $_FILES['uploaded_file']['error'] value.
        switch ($_FILES['uploaded_file']['error']) {
            case UPLOAD_ERR_OK:
                break;
            case UPLOAD_ERR_NO_FILE:
                throw new RuntimeException('No file sent.');
            case UPLOAD_ERR_INI_SIZE:
            case UPLOAD_ERR_FORM_SIZE:
                throw new RuntimeException('Exceeded filesize limit.');
            case UPLOAD_ERR_EXTENSION:
                throw new RuntimeException('File upload canceled/stopped.');
            case UPLOAD_ERR_CANT_WRITE:
                throw new RuntimeException('Can\t write to disk.');
            default:
                throw new RuntimeException('Unknown error.');
        }

        // Verify input name
        $in_filename = mb_basename( $_FILES['uploaded_file']['name']);

        if ( preg_match ( '/\<\>\;\:\*\#/' , $in_filename) )
            throw new Exception('Error: Invalid characters in input name');

        // Not allowed any index.*
        if ( preg_match ( '/^index/' , $in_filename ))
            throw new Exception('Error: index.* names are not allowed');


        // Verify if filename exists  in upload folder and adjust name
        $filename=$in_filename;
        if ( $config['allow_overwrite'] == "no" ) {
            $i = 0;
            $parts = pathinfo($in_filename);
            while (file_exists($config['upload_folder']. "/" . $filename)) {
                $i++;
                $filename = $parts["filename"] . "-" . $i . "." . $parts["extension"];
            }
        }
        $path = $config['upload_folder']. "/" . $filename ;

        if(move_uploaded_file($_FILES['uploaded_file']['tmp_name'], $path)) {
            if ( $config['do_chmod']  == 'yes' ) {
                // set proper permissions on the new file
                chmod($path , $config['chmod'] );
            }
            $message =  "The file ".  $in_filename .  " has been uploaded";
        } else{
            $message =  "There was an error uploading the file, please try again!";
        }
    }
} catch(Exception $e){
    $message = "<b>ERROR:</b> ". $e->getMessage();
}

template_upload_message($message);
template_upload_end();
?>
