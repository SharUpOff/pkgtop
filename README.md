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
$ pkgtop [lines [columns]] [--skip <count>] [--exclude <name>] [--mark <name>] [--other] [--total] [--all] [--raw] [--version] [--help]
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
  $ pkgtop 5 --other
  [other]............................................................   61.35 MiB 
  libc6..............................................................   13.27 MiB 
  perl-base..........................................................    7.59 MiB 
  coreutils..........................................................    6.95 MiB 
  dpkg...............................................................    6.58 MiB 
  ```
- Show total:
  ```bash
  $ pkgtop 5 --other --total
  [other]............................................................   67.93 MiB 
  libc6..............................................................   13.27 MiB 
  perl-base..........................................................    7.59 MiB 
  coreutils..........................................................    6.95 MiB 
  [total]............................................................   95.74 MiB 
  ```
- Skip packages:
  ```bash
  $ pkgtop 5 --other --total --skip 2
  [other]............................................................   55.67 MiB 
  coreutils..........................................................    6.95 MiB 
  dpkg...............................................................    6.58 MiB 
  libssl3............................................................    5.69 MiB 
  [total]............................................................   74.87 MiB 
  ```
- Exclude package:
  ```bash
  $ pkgtop 5 --other --total --exclude libc6
  [other]............................................................   61.35 MiB 
  perl-base..........................................................    7.59 MiB 
  coreutils..........................................................    6.95 MiB 
  dpkg...............................................................    6.58 MiB 
  [total]............................................................   82.46 MiB 
  ```
- Exclude multiple packages:
  ```bash
  $ pkgtop 5 --other --total --exclude libc6 --exclude coreutils
  [other]............................................................   55.67 MiB 
  perl-base..........................................................    7.59 MiB 
  dpkg...............................................................    6.58 MiB 
  libssl3............................................................    5.69 MiB 
  [total]............................................................   75.52 MiB 
  ```
- Mark package:
  ```bash
  $ pkgtop 5 --other --total --mark coreutils
  [other]............................................................   67.93 MiB 
  libc6..............................................................   13.27 MiB 
  perl-base..........................................................    7.59 MiB 
  coreutils..........................................................    6.95 MiB<
  [total]............................................................   95.74 MiB 
  ```
- Mark multiple packages:
  ```bash
  $ pkgtop  5 --other --total --mark coreutils --mark [other]
  [other]............................................................   67.93 MiB<
  libc6..............................................................   13.27 MiB 
  perl-base..........................................................    7.59 MiB 
  coreutils..........................................................    6.95 MiB<
  [total]............................................................   95.74 MiB
  ```
- Do not limit the output:
  ```bash
  $ pkgtop --all
  libc6..............................................................   13.27 MiB 
  perl-base..........................................................    7.59 MiB
  ...
  libtirpc-common....................................................   32.00 KiB 
  libaudit-common....................................................   23.00 KiB 
  ```

# Dependencies

## ArchLinux
You may want to install `expac` to improve script performance:
```bash
$ time pkgtop &> /dev/null

real    0m0,576s
user    0m0,527s
sys     0m0,067s

$ sudo pacman -S expac
$ time pkgtop &> /dev/null

real    0m0,391s
user    0m0,245s
sys     0m0,120s
```

# Compatibility
- ✅ Ubuntu
  - ✅ 22.04 (TEST OK: 2022-07-16)
  - ✅ 20.04 (TEST OK: 2022-07-16)
  - ✅ 18.04 (TEST OK: 2022-07-16)
  - ✅ 16.04 (TEST OK: 2022-07-16)
  - ✅ 14.04 (TEST OK: 2022-07-16)
- ✅ Debian
  - ✅ 11 (TEST OK: 2022-07-16)
  - ✅ 10 (TEST OK: 2022-07-16)
  - ✅ 9 (TEST OK: 2022-07-16)
- ✅ Fedora
  - ✅ 37 (TEST OK: 2022-07-16)
  - ✅ 36 (TEST OK: 2022-07-16)
  - ✅ 35 (TEST OK: 2022-07-16)
  - ✅ 34 (TEST OK: 2022-07-16)
- ✅ RedHat
  - ✅ 9 (TEST OK: 2022-07-16)
  - ✅ 8 (TEST OK: 2022-07-16)
- ✅ CentOS
  - ✅ 7 (TEST OK: 2022-07-16)
- ✅ OpenSUSE
  - ✅ tumbleweed (TEST OK: 2022-07-16)
  - ✅ leap
    - ✅ 15 (TEST OK: 2022-07-16)
- ✅ ArchLinux (TEST OK: 2022-07-16)
- ✅ OpenWRT (TEST OK: 2022-07-16)

# Contribution
🛠 You are welcome to add support for other distributions, fix bugs or improve functionality. Please, do not forget to add tests.

## Add distribution support
Create a plugin file `src/includes/distributions/yourdistro/01_package-manager.sh`
```bash
# YourDistro (package-manager)
if command -v package-manager &> /dev/null; then
    # write installed packages to the STDOUT using format: %{bytes}d %{name}s\n
    package-manager --installed --format='%{bytes}d %{name}s\n'

    # prevent other plugins from running
    exit $?  
fi
```

Yor plugin should write installed packages using format `%{bytes}d %{name}s\n` to the `STDOUT`:
```bash
2131 foo
34534 bar
```

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
