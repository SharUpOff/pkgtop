# Changelog

## 1.1.0

### Features
- Support for other operating systems
  - macOS
- Support for multiplatform package management systems
  - Homebrew

### Fixes
- Compatibility
  - zsh
  - awk without unicode support

## 1.0.0

### Features
- Shows largest installed packages
- Follows terminal and prompt dimensions by default
- Colour output by default
- Support for custom output size
- Options to show `other` and `total` packages size
- Options to `skip` first N and `exclude` specified packages
- Option to `mark` specified packages
- Option for unlimited output
- Support for GNU/Linux distributions
  - dpkg
    - Ubuntu (>=14.04, <=22.04)
    - Debian (>=9, <=11)
  - rpm
    - Fedora (>=34, <=37)
    - RedHat (>=8, <=9)
    - CentOS (==7)
    - OpenSUSE (tumbleweed, leap==15)
  - pacman (expac can be used for better performance)
    - ArchLinux
  - opkg
    - OpenWRT
