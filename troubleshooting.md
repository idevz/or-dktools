#### Non matched kernel pkg for systmetap installation


If we using the nor matching kernel pkgs, we'll got faults like belowing:
```bash
[root@fd8d7744b7a2 /]# stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'
Checking "/lib/modules/3.10.0-693.el7.x86_64/build/.config" failed with error: No such file or directory
[root@fd8d7744b7a2 /]# ll /lib/modules
total 8
drwxr-xr-x. 7 root root 4096 Aug  2 22:07 3.10.0-862.3.2.el7.x86_64
[root@fd8d7744b7a2 /]# ln -sf /lib/modules/3.10.0-862.3.2.el7.x86_64 /lib/modules/3.10.0-693.el7.x86_64
[root@fd8d7744b7a2 /]# ll /lib/modules
total 8
lrwxrwxrwx. 1 root root   38 Aug  2 22:41 3.10.0-693.el7.x86_64 -> /lib/modules/3.10.0-862.3.2.el7.x86_64
drwxr-xr-x. 7 root root 4096 Aug  2 22:07 3.10.0-862.3.2.el7.x86_64
[root@fd8d7744b7a2 /]# stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'
Pass 1: parsed user script and 471 library scripts using 139676virt/41796res/3448shr/38388data kb, in 480usr/70sys/628real ms.
semantic error: while resolving probe point: identifier 'kernel' at /usr/share/systemtap/tapset/linux/vfs.stp:915:18
        source: probe vfs.read = kernel.function("vfs_read")
                                 ^

semantic error: missing x86_64 kernel/module debuginfo [man warning::debuginfo] under '/lib/modules/3.10.0-693.el7.x86_64/build'

semantic error: resolution failed in alias expansion builder

semantic error: while resolving probe point: identifier 'vfs' at <input>:1:7
        source: probe vfs.read {printf("read performed\n"); exit()}
                      ^

semantic error: no match

Pass 2: analyzed script: 0 probes, 0 functions, 0 embeds, 0 globals using 142996virt/44900res/5364shr/39608data kb, in 60usr/210sys/266real ms.
Pass 2: analysis failed.  [man error::pass2]
```
