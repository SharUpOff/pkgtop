# pkgtop
Show largest installed packages.

## Installation
```bash
curl https://raw.githubusercontent.com/SharUpOff/pkgtop/main/dist/pkgtop.sh -so - | sudo tee /usr/local/bin/pkgtop > /dev/null
```
```bash
chmod 755 /usr/local/bin/pkgtop
```

## Usage
```bash
pkgtop 10
```
Output:
```
libc6..............................................................   13.27 MiB 
perl-base..........................................................    7.59 MiB 
coreutils..........................................................    6.95 MiB 
dpkg...............................................................    6.58 MiB 
libssl3............................................................    5.69 MiB 
apt................................................................    4.06 MiB 
util-linux.........................................................    3.32 MiB 
libapt-pkg6.0......................................................    3.10 MiB 
libstdc++6.........................................................    2.69 MiB 
libc-bin...........................................................    2.48 MiB 
```

The colour output makes it possible to compare installed packages visually:

![screenshot](pkgtop.png)

# Compatibility
- ✅ Ubuntu
  - ✅ 22.04 (TEST OK: 2022-06-25)
  - ✅ 20.04 (TEST OK: 2022-06-25)
  - ✅ 18.04 (TEST OK: 2022-06-25)
  - ✅ 16.04 (TEST OK: 2022-06-25)
  - ✅ 14.04 (TEST OK: 2022-06-25)
- ✅ Debian
  - ✅ 11 (TEST OK: 2022-06-25)
  - ✅ 10 (TEST OK: 2022-06-25)
  - ✅ 9 (TEST OK: 2022-06-25)
- ✅ ArchLinux (TEST OK: 2022-06-25)
- ✅ OpenWRT (TEST OK: 2022-06-25)

# Testing
There are some regression tests provided for compatible platforms.

## Run tests
```bash
docker compose -f docker-tests-run.yml up
```
Output:
```bash
pkgtop-test-debian-11-1 exited with code 0
pkgtop-test-ubuntu-16.04-1 exited with code 0
pkgtop-test-ubuntu-22.04-1 exited with code 0
pkgtop-test-ubuntu-20.04-1 exited with code 0
pkgtop-test-archlinux-1 exited with code 0
pkgtop-test-ubuntu-14.04-1 exited with code 0
pkgtop-test-ubuntu-18.04-1 exited with code 0
pkgtop-test-debian-9-1 exited with code 0
pkgtop-test-debian-10-1 exited with code 0
pkgtop-test-openwrtorg-1 exited with code 0
```

## How does testing work
- The actual script is running in a docker container for each of compatible platforms;
- The current terminal output is compared with previously created reference file:
```bash
bash ./dist/pkgtop.sh 25 80 | diff ./data/ubuntu-22.04.txt -
```

## Update reference data
```bash
docker compose -f docker-tests-update.yml up
```
