# Gitty RSA

## Description

We find some suspicious activities in our organization's network...

## Setup

You may want to re-generate `./docker/res/secret.txt`.

```bash
cd docker && docker-compose up --build
```

Then proxy host's `17365` to container's `22` port.

make sure `ctf.anzupop.com`'s 17365 is the port your proxy listens on.

## Solve

1. From `out.pcapng`, got two git packs.
2. From push, we get a png picture. `strings` told us that we should connect to `ctf.anzupop.com 17365`.
3. From pull, we get a snipped private key. Try your best to recover it.
4. You should now find out that a `sshd` is running on `ctf.anzupop.com 17365`.
5. `ssh ctf.anzupop.com -p 17365` shows `hello, [chall]engers`.
6. Use user `chall` and your recovered private key to connect.
7. From `welcome.txt`, we can learn that it's a `SECRET`.
8. `find / | grep secret`.
