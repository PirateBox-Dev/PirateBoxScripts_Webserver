<?php

/*********************************************
 * This File is a default template for the
 * script upload_handler/upload.php
 *
 * If you want to customize it, place it to a
 * folder content/php_templates/
 *
 * (c) 2018 Matthias Strubel - GPL3
 *********************************************/


function template_upload_start(){
?>
<!DOCTYPE html>
<html>
<head>
  <title>Upload your files</title>
</head>
<body>
  <form enctype="multipart/form-data" action="upload.php" method="POST">
    <input type="file" name="uploaded_file"></input><br />
    <input type="submit" value="Upload"></input>
  </form>
<?php
}

function template_upload_message($message){
    echo "<pre>".$message."<pre>";
}

function template_upload_end(){
?>
</body>
</html>
<?php
}

?>
