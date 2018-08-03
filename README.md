# or-dktools

*building and packaging some OR tools for bare or docker.*

*sometimes we may need start a local file server for download the packages we need (like some GFW things), 
you can find The Directory Structure Specification in [or-dktools-pkgs](https://github.com/idevz/or-dktools-pkgs).*

## systemtap

when we install systemtap we must confirm that we have already install the corresponding version's kernel pkgs,
just like:

* kernel-${KERNEL_VERSION}.rpm
* kernel-devel-${KERNEL_VERSION}.rpm
* kernel-debuginfo-common-x86_64-${KERNEL_VERSION}.rpm
* kernel-debuginfo-${KERNEL_VERSION}.rpm

if the kernel pkg's version is not matching with `$(uname -r)`, then our installation will be faile.

if we building a docker image for systemtap, we should also confirm that the kernel pkgs in the container 
must be matching with our host's `$(uname -r)`.
thus, we have `.kernel-url-conf` script to conf a `${KERNEL_URL_MAP}` for the kernel pkgs downloading,
and we also check to using the specified KERNEL_URL to download install the matching kernel pkgs.
