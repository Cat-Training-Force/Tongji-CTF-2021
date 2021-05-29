# Igenerev

## Message

> I've heard you can decrypt the polyaphabetic cipher and the rot cipher. But how about this "key rot polyaphabetic cipher"?
>
> ```
> MVR YZKFFKM CNIMGJLG UO VAJ JVMNVGKJ QVVQMT NL GNN TXUXOGOWO GFMIEK WH NMG QNG BK O IAGRMFGOYEBB VTKFRICTA LNSFYNA MMX XKH NXSZHU CPG HBDUKA VXCM PGW DX MFRGCMF FL VTCMTPTOSA LIGLFK POYPGKX KUOLP VFG RGBQNR US HAWMXS WAJRDKWZTZYE IPW MVR OTCZ BG ZSKVY BYAUFKCKTEWFRRAVXSBBT FQVA UFNINA
> ```

## Hints

> Vigenère cipher 的 cryptanalysis 资料可见 https://pages.mtu.edu/~shene/NSF-4/Tutorial/index.html
>
> 其中算法可以用来参考解本题。

## Writeup

题目信息提示为 `key rot`。实际意义为，在 Vigenère cipher 的基础上，对每个单词的加密都做一次密钥的 left-shift，如同 `Vigenere` 变为 `Igenerev`。理解了这一点之后，就可以看出这是把空格也算入加密算法内的 Vigenère。

之后的分析便完全适用用来分析 Vigenère cipher 的 Kasiski test 和 Friedman test。具体的密码分析过程在 Hint 给到的网页中有详细的讲解，并附有相关程序。

一个便捷的方法是，用任意字母替换明文中的空格再进行密码分析。比如，无论用任何字母替换空格后做 Kasiski test 和 Friedman test 后均认为密钥长度很可能是 9，而其他的推断则易受替换字母的影响。

确定密钥长度为 9 后，分组进行熵分析，此时使用不同字母替换空格的分析结果不同，如用 a 替换时熵分析给出的密钥是 `TONGJIVTS`，但用于解密得到的明文有不少错误的单词。此时有两种方法：尝试使用所有字母各替换一遍，统计各组的密钥频率，最后发现 `TONGJICTF` 为各组频率最高的组合；或进行熵分析时留意其他的可能密钥，比如用 `f` 替换空格时熵分析给出的最可能密钥为 `TONCJOCTB`,第八组 `B` 熵分析的结果为 2.08，但 `F` 的熵分析结果为 `2.09`。同样过程观察两三个字母的替换结果便可确定密钥为 `TONGJICTF`。

以上过程若辅助采用分析明文单词的方法可以更快，甚至不需要空格替换或熵分析便可推出密钥。

明文为：

```
THE PRIMARY WEAKNESS OF THE VIGENERE CIPHER IS THE REPEATING NATURE OF ITS KEY IF A CRYPTANALYST CORRECTLY GUESSES THE KEY LENGTH THE CIPHER TEXT CAN BE TREATED AS INTERWOVEN CAESAR CIPHERS WHICH CAN EASILY BE BROKEN INDIVIDUALLY AND THE FLAG IS TJCTF IKNOWCAROLISLISTENING WITH BRACES
```

因此 flag 为 `tjctf{IKNOWCAROLISLISTENING}`。

