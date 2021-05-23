<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>登陆</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="login">
  <h1>Login</h1>
    <form action="index.php" method="post">
      <input type="text" name="username" placeholder="用户名" required="required" />
      <input type="password" name="password" placeholder="口令" required="required" />
    <!-- 以防忘记： Admin:admin. -->
    <!-- 我才不担心有人发现这个注释。让那些可恶的黑客们知道了登陆信息又怎样，反正只有通过同济的网站才能登陆。 -->
      <button type="submit" class="btn btn-primary btn-block btn-large">Let me in.</button>
    </form>
<?php
  $username = isset($_POST['username']) ? $_POST['username'] : '';
  $password = isset($_POST['password']) ? $_POST['password'] : '';
  $referer = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : '';
  if ($username !== '' || $password !== '') {
    if ($username === 'Admin' && $password === 'admin') {
      if (preg_match('/^\S*tongji\.edu\.cn$/', $referer)) {
        echo '<p>tjctf{F4nCY_W38$17E_P0Or_SecUr1TY}</p>';
      } else {
        echo '<p>Curse you, Hacker!</p>';
      }
    } else {
      echo '<p>用户名或密码错误</p>';
    }
  }
?>
</div>
</body>
</html>