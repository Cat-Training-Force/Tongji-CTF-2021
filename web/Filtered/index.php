<?php
  highlight_file(__FILE__);
  if (isset($_GET['file'])) {
    $file = $_GET['file'];
    if (preg_match('/index|base64|rot|toupper|tolower|quoted|compress|decompress|\.\./', $file)) {
      die('Not Allowed');
    }
    @include($file);
  }
?>

