#!/bin/bash

set -o nounset
set -o errexit

function usage() {
    cat <<EOF

    Usage: ${0} subdir

    OPTIONS:
      -h        Show usage

EOF
exit
}

while getopts "h" OPTION; do
  case $OPTION in
    h) usage ;;
  esac
done

if [ $# -eq 0 ]; then
  usage
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SUBDIR=$1
VERSIONS=( 6 7 )
SED=`which sed`

for i in "${VERSIONS[@]}"; do
  if [[ -d $DIR/$i/$SUBDIR ]]; then
    echo "$DIR/$i/$SUBDIR exists."
    if [[ $i == '7' ]]; then
      exit
    fi
  else
    cp -R $DIR/$i/contrib $DIR/$i/$SUBDIR
    find $DIR/$i/$SUBDIR -type f \
      -exec $SED -i "s/contrib/${SUBDIR}/g" {} \;
  fi
done
