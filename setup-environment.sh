#!/usr/bin/env bash

# This script should be tested against shellcheck .  For more information,
#   see: http://www.shellcheck.net/

# set -e
# set -x

minimum_version=4
if [ "$BASH_VERSION" \< "$minimum_version" ]; then
  echo "This script requires Bash version 4.x or later."
  exit 1
fi

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "The script '${BASH_SOURCE[0]}' is being sourced."
else
  echo "
  The script '${BASH_SOURCE[0]}' is meant to be sourced only.
  Can not continue.
"
  exit 1
fi

VAR_PREFIX="VAR_PREFIX_"

tmp=$(mktemp -d)
pushd "$tmp" > /dev/null

function cleanup {
  popd > /dev/null
  if [ -f "$tmp" ]; then
    rm -rf "$tmp"
  fi
}

function errexit {
  cleanup
  echo "$1" 1>&2
  return 1
}

# FIXME: Add this back.  It was commented for testing purposes only.
# if [ "$(whoami)" != "biocbuild" ]; then
#   errexit "This script must be run as user 'biocbuild'"
# fi


# Download the config file locally
curl -sSL  https://master.bioconductor.org/config.yaml -o config.yaml

# Based on:
# - http://stackoverflow.com/a/21189044/320399
# - https://gist.github.com/pkuczynski/8665367
function parse_yaml {
   local prefix=$2
   # shellcheck disable=SC2155
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   # shellcheck disable=SC2086
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function debugParsedYaml {
  echo "Printing parsed yaml"
  parse_yaml config.yaml "$VAR_PREFIX"
  echo "***********"
}

function setupEnvironment {
  # DEBUG ONLY: Run the parser, and print all variables into current shell
  # debugParsedYaml

  echo "***********************"
  echo "Configuring environment"
  # The string to prepend to each variable

  # Run the parser, all variables found are declared in local shell .
  # Unfortunately, this means we have `disable=SC2154` throughout the code.
  eval "$(parse_yaml config.yaml ${VAR_PREFIX})"
  echo "***********************"

  # shellcheck disable=SC2154
  echo "
Bioconductor release version :     ${VAR_PREFIX_release_version}"
  # shellcheck disable=SC2154
  echo "Bioconductor development version : ${VAR_PREFIX_devel_version}
"

  # NB: The linux build boxes are also the `controller` systems in the BBS.
  # shellcheck disable=SC2154
  LINUX_DEV_BLDR="$VAR_PREFIX_active_devel_builders_linux"
  # shellcheck disable=SC2154
  LINUX_REL_BLDR="$VAR_PREFIX_active_release_builders_linux"

  LINUX_BUILD_HTML_ROOT="/home/biocbuild/public_html/BBS"

  export SOFTWARE_BUILD_NODES
  export DATA_BUILD_NODES
  export INVESTIGATION_DIR

  # FIXME: Remove second condition, for testing purposes only
  if [[ $(hostname) = "$LINUX_DEV_BLDR" ]] || [[ $(hostname) = "work" ]]; then
    echo "This machine is the linux builder for devel."
    SOFTWARE_BUILD_NODES="${LINUX_BUILD_HTML_ROOT}/${VAR_PREFIX_devel_version}/bioc/nodes"
    DATA_BUILD_NODES="${LINUX_BUILD_HTML_ROOT}/${VAR_PREFIX_devel_version}/data-experiment/nodes"
    INVESTIGATION_DIR="/home/biocbuild/bbs-${VAR_PREFIX_devel_version}-bioc/log"
  elif [[ $(hostname) = "$LINUX_REL_BLDR" ]]; then
    echo "This machine is the linux builder for release."

    SOFTWARE_BUILD_NODES="${LINUX_BUILD_HTML_ROOT}/${VAR_PREFIX_release_version}/bioc/nodes"
    DATA_BUILD_NODES="${LINUX_BUILD_HTML_ROOT}/${VAR_PREFIX_release_version}/data-experiment/nodes"
    INVESTIGATION_DIR="/home/biocbuild/bbs-${VAR_PREFIX_release_version}-bioc/log"
  else
    errexit "This machine isn't the linux   builder for release or devel, cannot continue."
  fi

  echo "
The environment is now configured with the following environment variables:

  SOFTWARE_BUILD_NODES : '$SOFTWARE_BUILD_NODES'
  DATA_BUILD_NODES :     '$DATA_BUILD_NODES'
  INVESTIGATION_DIR :    '$INVESTIGATION_DIR'
"

  cleanup
  for varAndVal in $(printenv) ; do
    # echo "Checking stuff, varAndVal = $varAndVal"
     case ${varAndVal} in
       "$VAR_PREFIX"* )
        # eval \$${varAndVal}=
        echo "WARNING: Unsetting $varAndVal"
        eval unset \$"${varAndVal}"
       ;;

      esac
   done

   unset -f setupEnvironment
   unset -f debugParsedYaml
   unset -f parse_yaml
   unset -f exitMsg
   unset -f cleanup
   echo "Finished configuring environment."
}

setupEnvironment
return 0
