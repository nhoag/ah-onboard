#!/bin/bash

set -o nounset
set -o errexit

function usage() {
    cat <<EOF

    Usage: ${0} [-y] docroot-path 6|7 [subdir]

    OPTIONS:
      -h        Show usage
      -y        Assume 'yes' for prompts

EOF
exit
}

while getopts "hy" OPTION; do
  case $OPTION in
    h) usage          ;;
    y) YES=1          ;;
  esac
done

shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
  usage
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CODEBASE=$1
VERSION=$2
DRUSH=`which drush`
CONTRIB=${3:-'modules'}
CONFIRM=${YES:-0}

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
  DIFF=("${MODULES[@]}")
else
  printf "%s\n" "${PRESENT[@]}" \
    | xargs -I {} echo "{} already in codebase."
  DIFF=($(diff MODULES[@] PRESENT[@]))
fi

function makefile() {
  if [[ $3 == 'modules' ]]; then
    cat <<EOF
core = $1.x
api = 2

; Modules
projects[] = $2
EOF
  else
    cat <<EOF
core = $1.x
api = 2

; Modules
projects[$2][subdir] = $3
EOF
  fi
}

if [[ ${#DIFF[@]} -eq 0 ]]; then
  echo -e "All modules already present in the codebase."
  exit
else
  if [[ $CONTRIB == 'modules' ]]; then
    CONTRIB_PATH="sites/all/modules"
  else
    CONTRIB_PATH="sites/all/modules/$CONTRIB"
  fi
  if [[ $CONFIRM != 1 ]]; then
    while [[ true ]]; do
      read -p "Modules will be added at $CONTRIB_PATH. Proceed? [y/n]:" answer
      case $answer in
        [yY]* ) break ;;
        [nN]* ) echo -e "\n  Script aborted.\n"
                exit ;;
        * ) echo -e "\n  Answer must be either y/n.\n" ;;
      esac
    done
  fi
  cd $CODEBASE
  for i in "${DIFF[@]}"; do
    makefile $VERSION $i $CONTRIB \
      | $DRUSH make --no-core -y php://stdin
  done
fi

GIT=`which git`
echo ""

for i in "${DIFF[@]}"; do
  find . -type d -name $i \
    | xargs -I {} sh -c "$GIT add {} ; $GIT commit -q -m \"Adds $i\""
  echo -e "  Added and committed $i"
done

echo -e "\nScript completed successfully.\n"
