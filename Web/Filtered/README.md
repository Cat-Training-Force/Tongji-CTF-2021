# Filtered

## Message

Try your best not to get rolled ; - )

## 考点

- [PHP stream filter](https://www.php.net/manual/en/filters.php)

  源码中 `preg_match('/index|base64|rot|toupper|tolower|quoted|compress|decompress|\.\./', $file)` 与其说是过滤更不如说是提示。

  `include` 直接传入文件，如果有 `<?php` 串则会直接执行而非输出字符串。因此需要用 stream filter 将 `flag.php` 转化为无 `<?php` 的文本以输出其内容。

## Writeup

1. 尝试访问 `/?file=flag.php`，确认存在 `flag.php` 文件。
2. 用任意未被过滤的 PHP stream filter 处理 `flag.php` 文件即可。