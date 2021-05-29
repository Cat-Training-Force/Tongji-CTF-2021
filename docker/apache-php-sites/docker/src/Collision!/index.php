<?php
  highlight_file(__FILE__);
  include('flag.php');
  if(isset($_GET['a']) && isset($_GET['b']))
  {
    $a = (string)$_GET['a'];
    $b = (string)$_GET['b'];
    if (strlen($a) > 500 || strlen($b) > 500) {
      die("Too long!");
    }
    if ($a === $b) {
      die("Don't play Tricks!");
    }
    if (!preg_match('/I believe/', $a) || !preg_match('/in SHA1!/', $b)) {
      die('Go away you unbeliever!');
    }
    if (sha1($a) !== sha1($b)) {
      die('You failed.');
    }
    echo $flag;
  }
?>