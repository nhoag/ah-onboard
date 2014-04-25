#!/bin/bash

set -o nounset
set -o errexit

function usage() {
    cat <<EOF

    Usage: ${0} path-to-codebase [6|7] [subdir]

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
CODEBASE=$1
VERSION=$2
DRUSH=`which drush`
CONTRIB=${3:-'modules'}

function diff() {
  awk 'BEGIN{RS=ORS=" "}
    {NR==FNR?a[$0]++:a[$0]--}
    END{for(k in a)if(a[k])print k}' <(echo -n "${!1}") <(echo -n "${!2}")
}

MODULES=( acquia_connector fast_404 memcache )

PRESENT=(
  `printf "%s\n" "${MODULES[@]}" \
    | xargs -I {} find $CODEBASE -type d -name {} \
    | xargs -I {} basename {}`
)

if [[ ${#PRESENT[@]} -eq 0 ]]; then
  echo "Projects not found. Proceeding..."
  DIFF=("${MODULES[@]}")
else
  printf "%s\n" "${PRESENT[@]}" \
    | xargs -I {} echo "{} already in codebase."
  DIFF=($(diff MODULES[@] PRESENT[@]))
fi

CONTRIB_CHECK=$(find $CODEBASE/"sites"/"all" -type d -name $CONTRIB)

if [[ -z "$CONTRIB_CHECK" ]]; then
  echo "Error: $CONTRIB dir not found."
  exit
else
  CONTRIB_DIR=$( basename "${CONTRIB_CHECK}" )
fi

if [[ ${#DIFF[@]} -eq 0 ]]; then
  echo "All modules are present in the codebase. Exiting script..."
  exit
else
  cd $CODEBASE
  printf "%s\n" "${DIFF[@]}" \
    | xargs -I {} $DRUSH make \
      --no-core -y \
      $DIR/$VERSION/$CONTRIB_DIR/{}.make
fi

GIT=`which git`

for i in "${DIFF[@]}"; do
  find . -type d -name $i \
    | xargs -I {} sh -c 'git add {} ; git commit -m "Adds {}"'
done
