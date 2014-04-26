ah-onboard
=======================

Bash scripts to automate onboarding tasks.

#### Install
```
git clone git@github.com:nhoag/ah-onboard.git
```

### Add modules

Download, add, and commit the following contrib modules:

- [acquia_connector](https://drupal.org/project/acquia_connector)
- [fast_404](https://drupal.org/project/fast_404)
- [memcache](https://drupal.org/project/memcache)

#### Features

- Checks for the presence of each module before making any changes.
- Optionally locate modules in subdirectory of 'sites/all/modules'.
- Assumes Git.

#### Command

```
./ah-onboard/modules.sh [-y] docroot-path 6|7 [subdir]
```
