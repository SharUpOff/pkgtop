# pkgtop
Show largest installed packages.

## Installation
```bash
curl https://raw.githubusercontent.com/SharUpOff/pkgtop/main/dist/pkgtop.sh -so - | sudo tee /usr/local/bin/pkgtop > /dev/null
```
```bash
sudo chmod 755 /usr/local/bin/pkgtop
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

## Arguments
```bash
$ pkgtop [count] [width] [skip]
```

## Features
- Follow terminal and prompt dimensions;
- Specify results count:
  ```bash
  $ pkgtop 3
  libc6..............................................................   13.27 MiB 
  perl-base..........................................................    7.59 MiB 
  coreutils..........................................................    6.95 MiB 
  ```
- Specify width:
  ```bash
  $ pkgtop 3 42
  libc6........................   13.27 MiB 
  perl-base....................    7.59 MiB 
  coreutils....................    6.95 MiB 
  ```
- Skip results:
  ```bash
  $ pkgtop 3 42 2
  coreutils....................    6.95 MiB 
  dpkg.........................    6.58 MiB 
  libssl3......................    5.69 MiB 
  ```
- Skip arguments:
  ```bash
  $ pkgtop 3 "" 2
  coreutils..........................................................    6.95 MiB 
  dpkg...............................................................    6.58 MiB 
  libssl3............................................................    5.69 MiB 
  ```

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
- ✅ Fedora
  - ✅ 37 (TEST OK: 2022-06-26)
  - ✅ 36 (TEST OK: 2022-06-26)
  - ✅ 35 (TEST OK: 2022-06-26)
  - ✅ 34 (TEST OK: 2022-06-26)
- ✅ RedHat
  - ✅ 9 (TEST OK: 2022-06-26)
  - ✅ 8 (TEST OK: 2022-06-26)
- ✅ CentOS
  - ✅ 7 (TEST OK: 2022-06-26)
- ✅ ArchLinux (TEST OK: 2022-06-25)
- ✅ OpenWRT (TEST OK: 2022-06-26)

# Contribution
🛠 You are welcome to add support for other distributions, fix bugs or improve functionality. Please, do not forget to add tests.

# Testing
There are some regression tests provided for compatible distributions.

## Run tests
```bash
docker compose -f docker-tests-run.yml up
```
Output:
```bash
pkgtop-test-ubuntu-22.04-1 exited with code 0
pkgtop-test-ubuntu-20.04-1 exited with code 0
pkgtop-test-ubuntu-18.04-1 exited with code 0
pkgtop-test-ubuntu-16.04-1 exited with code 0
pkgtop-test-ubuntu-14.04-1 exited with code 0
pkgtop-test-debian-11-1 exited with code 0
pkgtop-test-debian-10-1 exited with code 0
pkgtop-test-debian-9-1 exited with code 0
pkgtop-test-fedora-37-1 exited with code 0
pkgtop-test-fedora-36-1 exited with code 0
pkgtop-test-fedora-35-1 exited with code 0
pkgtop-test-fedora-34-1 exited with code 0
pkgtop-test-redhat-9-1 exited with code 0
pkgtop-test-redhat-8-1 exited with code 0
pkgtop-test-centos-7-1 exited with code 0
pkgtop-test-archlinux-1 exited with code 0
pkgtop-test-openwrtorg-1 exited with code 0
```

## How does testing work
- The actual script is running in a docker container for each of compatible distributions;
- The current terminal output is compared with previously created reference file:
```bash
bash ./dist/pkgtop.sh 25 80 | diff ./data/ubuntu-22.04.txt -
```

## Update reference data
```bash
docker compose -f docker-tests-update.yml up
```
