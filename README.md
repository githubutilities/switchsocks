# Socks Proxy Switcher

Unix-like command line system(like `Mac OSX`) currently does have `socks` proxy support, this switcher enable `socks` proxy for `git` command for Mac.


# Installation

1. Run the following command first

```sh
brew tap githubutilities/tap
brew install switchsocks
```

2. Add the following line to `.bash_profile`

```config
alias switchsocks='source switchsocks_helper.sh'
```

# Usage

* Run `switchsocks` whenever you want to switch to socks proxy


# Uninstallation

```sh
brew uninstall switchsocks
```


# Reference

* [smart_switcher by springlie](https://github.com/springlie/smart_switcher/blob/master/smart_switcher.sh)