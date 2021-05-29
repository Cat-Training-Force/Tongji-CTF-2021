# deleted

## Message

I've deleted the flag.
You won't get it.

## Hints

- I hate crawlers.

## 考点

- `robots.txt` 泄露网站目录信息。

  `robots.txt` 常用于（从道德上）限制爬虫，但也同时泄露网站目录结构。

- python `os.remove` 函数

  ```python
  # test.py
  import os
  
  print('------------------------')
  file = open('test')
  print('------------------------')
  os.remove('test')
  print('------------------------')
  ```

  `strace python test.py 2 > test.log` 跟踪系统调用，得到输出：

  ```c
  write(1, "------------------------\n", 25) = 25
  openat(AT_FDCWD, "test", O_RDONLY|O_CLOEXEC) = 3 
  newfstatat(3, "", {st_mode=S_IFREG|0644, st_size=0, ...}, AT_EMPTY_PATH) = 0 
  ioctl(3, TCGETS, 0x7ffd85d66c10)        = -1 ENOTTY (Inappropriate ioctl for device)
  lseek(3, 0, SEEK_CUR)                   = 0 
  ioctl(3, TCGETS, 0x7ffd85d66a40)        = -1 ENOTTY (Inappropriate ioctl for device)
  write(1, "------------------------\n", 25) = 25
  unlink("test")                          = 0
  write(1, "------------------------\n", 25) = 25
  ```

  可见 `os.remove` 没做多余的事情，就是一个 `unlink`。

- `/proc` 目录， file descriptor 及 `open`, `unlink` 系统调用常识。

  `man 5 proc` 命令查看 `/proc` 伪文件系统的 manual：

  > NAME
  > 	proc - process information pseudo-filesystem
  >
  > DESCRIPTION
  > 	The  `proc` filesystem is a pseudo-filesystem which provides an interface to kernel data structures.  It is commonly mounted at /proc.  Typically, it is mounted automatically by the system, but it can also be mounted manually using a command such as:
  >
  >      mount -t proc proc /proc
  >
  > ​	Most of the files in the `proc` filesystem are read-only, but some files are writable, allowing kernel variables to be changed.
  >
  > ...
  
  部分 file discriptor 相关内容：
  
  >...
  >
  >/proc/[pid]/fd/
  >	This is a subdirectory containing one entry for each file which the process has open, named by its file descriptor, and which is a symbolic link to the actual file.  Thus, 0 is standard input, 1 standard output, 2 standard error, and so on.
  >
  >...
  >
  >​	Most systems provide symbolic links `/dev/stdin`, `/dev/stdout`, and `/dev/stderr`, which respectively link to the files `0`, `1`, and `2` in `/proc/self/fd`.
  >
  >...
  
  程序打开的文件的 fd 会出现在该程序的 `/proc/self/fd` 目录中，且 `0`, `1`, `2` 三个文件也已被系统占用。
  
  `man 2 open` 命令查看 `open` 系统调用的 manual：
  
  > ...
  >
  > DESCRIPTION
  >     The  `open`()  system call opens the file specified by `pathname`.  If the specified file does not exist, it may optionally (if `O_CREAT` is specified in `flags`) be created by `open`().
  >
  > ​    The return value of `open`() is a file descriptor, a small, nonnegative integer that is used in subsequent system calls (`read`(2), `write`(2), `lseek`(2), `fcntl`(2),  etc.) to refer to the open file.  The file descriptor returned by a successful call will be the lowest-numbered file descriptor not currently open for the process.
  >
  > ...
  
  可知当程序第一次调用 `open` 系统调用时 `fd` 将为 `3`。
  
  `man 2 close` 命令查看 `close` 系统调用的 manual：
  
  > ...
  >
  > DESCRIPTION
  >     `close`()  closes  a file descriptor, so that it no longer refers to any file and may be reused.  Any record locks (see `fcntl`(2)) held on the file it was associated with, and owned by the process, are removed (regardless of the file descriptor that was used to obtain the lock).
  >
  > ​    If `fd` is the last file descriptor referring to the underlying open file description (see `open`(2)), the resources associated with the open file  description are freed; if the file descriptor was the last reference to a file which has been removed using `unlink`(2), the file is deleted.
  >
  > ...
  
  `man 2 unlink` 命令查看 unlink 系统调用的 manual：
  
  > ...
  >
  > DESCRIPTION
  >     `unlink`() deletes a name from the filesystem.  If that name was the last link to a file and no processes have the file open, the file is deleted and the space it was using is made available for reuse.
  >
  > ​    If the name was the last link to a file but any processes still have the file open, the file will remain in existence until the last file  descriptor referring to it is closed.
  >
  > ...
  
  因此 `os.remove` 后只要不调用 `close` 便不影响通过 `fd` 访问文件。

## Writeup

1. 访问 `/robots.txt` 发现存在路径 `/source`；

2. 访问 `/source` 发现程序源码，其中

   ```python
   flag = open('flag', 'r')
   os.remove('flag')
   ```

   表明 `flag` 文件被打开且被 `unlink`，无法直接通过文件系统访问。源码中

   ```python
   @app.route('/getfile', methods=['GET'])
   def getFile():
       fileName = request.args.get('file', '')
       try:
           with open(fileName, 'r') as file:
               return '<pre>' + html.escape(file.read()) + '</pre>'
       except:
           return "Error opening/reading file"
   ```

   表明 `/getfile` 路径存在任意文件下载漏洞。

3. 构造请求访问 `/getfile?file=/proc/self/fd/3` 即可读取 `flag`。

   （也可先访问 `/getfile?file=/proc/1/cmdline` 确认应用使用 docker 部署且进程 `pid=1`，之后构造 `/getfile?file=/proc/1/fd/3` 读取 `flag`。）

