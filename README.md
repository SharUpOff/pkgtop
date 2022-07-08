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
pkgtop
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
$ pkgtop [<lines> | --lines <lines> | --lines=<lines> | -l <lines>] [<columns> | --columns <columns> | --columns=<columns> | -c <columns>] [--exclude <name> | --exclude=<name> | -e <name>] [--exclude <name2> | --exclude=<name2> | -e <name2>] ... [--show-other | -o] [--show-total | -t] [--show-all | -a] [--help | -h]
```

## Features
- Follow terminal and prompt dimensions by default;
- Specify lines:
  ```bash
  $ pkgtop 5
  libc6..............................................................   13.27 MiB 
  perl-base..........................................................    7.59 MiB 
  coreutils..........................................................    6.95 MiB 
  dpkg...............................................................    6.58 MiB 
  libssl3............................................................    5.69 MiB 
  ```
- Specify columns:
  ```bash
  $ pkgtop 5 42
  libc6........................   13.27 MiB 
  perl-base....................    7.59 MiB 
  coreutils....................    6.95 MiB 
  dpkg.........................    6.58 MiB 
  libssl3......................    5.69 MiB 
  ```
- Show other:
  ```bash
  $ pkgtop 5 42 --show-other
  [other]......................   61.35 MiB 
  libc6........................   13.27 MiB 
  perl-base....................    7.59 MiB 
  coreutils....................    6.95 MiB 
  dpkg.........................    6.58 MiB 
  ```
- Show total:
  ```bash
  $ pkgtop 5 42 --show-other --show-total
  [other]......................   67.93 MiB 
  libc6........................   13.27 MiB 
  perl-base....................    7.59 MiB 
  coreutils....................    6.95 MiB 
  [total]......................   95.74 MiB 
  ```
- Exclude package:
  ```bash
  $ pkgtop 5 42 --show-other --show-total --exclude libc6
  [other]......................   61.35 MiB 
  perl-base....................    7.59 MiB 
  coreutils....................    6.95 MiB 
  dpkg.........................    6.58 MiB 
  [total]......................   82.46 MiB 
  ```
- Exclude multiple packages:
  ```bash
  $ pkgtop 5 42 --show-other --show-total --exclude libc6 --exclude coreutils
  [other]......................   55.67 MiB 
  perl-base....................    7.59 MiB 
  dpkg.........................    6.58 MiB 
  libssl3......................    5.69 MiB 
  [total]......................   75.52 MiB 
  ```
- Do not limit the output:
  ```bash
  $ pkgtop --show-all
  libc6..............................................................   13.27 MiB 
  perl-base..........................................................    7.59 MiB
  <...>
  libtirpc-common....................................................   32.00 KiB 
  libaudit-common....................................................   23.00 KiB 
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
- ✅ OpenSUSE
  - ✅ tumbleweed (TEST OK: 2022-07-06)
  - ✅ leap
    - ✅ 15 (TEST OK: 2022-07-06)
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
...
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
