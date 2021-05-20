<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Collision</title>
</head>
<body>
  <pre>
    <code>
$quests = [False, False];
if (isset($_GET['a']) and isset($_GET['b'])) {
  if ($_GET['a'] != $_GET['b']) {
    if (md5($_GET['a']) == md5($_GET['b'])) {
      $quests[0] = True;
    }
  }
}
//...
    </code>
  </pre>
  <?php
    $flag = 'tjctf{pHp_i$_th3_8E5T_1@NgUAGe}';
    $quests = [False, False];
    if (isset($_GET['a']) and isset($_GET['b'])) {
      if ($_GET['a'] != $_GET['b']) {
        if (md5($_GET['a']) == md5($_GET['b'])) {
          $quests[0] = True;
        }
      }
    }
    if ($quests[0]) {
      ?>
      <pre><code>
if (isset($_GET['c']) and isset($_GET['d'])) {
  if ($_GET['c'] != $_GET['d']) {
    if (sha1($_GET['c']) == sha1($_GET['d'])) {
      $quests[1] = True;
    }
  }
}
if ($quests[0] && $quests[1]) {
  echo $flag;
}
      </code></pre>
      <?php
      if (isset($_GET['c']) and isset($_GET['d'])) {
        if ($_GET['c'] != $_GET['d']) {
          if (sha1($_GET['c']) == sha1($_GET['d'])) {
            $quests[1] = True;
          }
        }
      }
    }
    if ($quests[0] && $quests[1]) {
      echo $flag;
    }
  ?>
</body>
</html>