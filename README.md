ah-onboard
=======================

Bash scripts to automate onboarding tasks.

#### Install
```
git clone git@github.com:nhoag/ah-onboard.git
```

#### Run

Download, add, and commit the following contrib modules:

- [acquia_connector](https://drupal.org/project/acquia_connector)
- [fast_404](https://drupal.org/project/fast_404)
- [memcache](https://drupal.org/project/memcache)

__Note:__ Checks for the presence of each module before making any changes. Optionally locate modules in 'sites/all/modules' subdirectory.

```
./ah-onboard/modules.sh /path/to/docroot-dir 6|7 [subdir]
```

#### Add support for a new subdir

For those times when contrib modules are located someplace other than 'sites/all/modules' or 'sites/all/modules/contrib':
```
./ah-onboard/add-subdir.sh subdir
```