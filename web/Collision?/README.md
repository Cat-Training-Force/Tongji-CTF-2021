# Collision?

## Message

真的确定这不是 Crypto 题？

## Writeup

### 考点

- PHP `==` 比较漏洞。

  `==` 比较在 type judging 时会将数字开头的字符串理解为数字类型，如 `3e5` 会被理解为 $3 \times 10^5$。

  若利用这一点解题，从 https://github.com/spaze/hashes 找 Hash 值以 `0e` 开头的字符串即可，PHP 会将 `==` 两遍的值都转为 0。

- PHP `md5`/`sha1` 函数对数组类型参数错误处理。

  `md5`/`sha1` 参数为数组时返回值为 `null`，所以只要让 `a, b` 和 `c, d` 分别为不同的数组即可绕过比较。

PHP 对 URL param 的 Hash 处理与比较的正确方法可参见 Collision! 题。

