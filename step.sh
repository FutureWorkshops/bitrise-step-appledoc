#!/bin/bash

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -e

#=======================================
# Functions
#=======================================

RESTORE='\033[0m'
RED='\033[00;31m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
GREEN='\033[00;32m'

function color_echo {
	color=$1
	msg=$2
	echo -e "${color}${msg}${RESTORE}"
}

function echo_fail {
	msg=$1
	echo
	color_echo "${RED}" "${msg}"
	exit 1
}

function echo_warn {
	msg=$1
	color_echo "${YELLOW}" "${msg}"
}

function echo_info {
	msg=$1
	echo
	color_echo "${BLUE}" "${msg}"
}

function echo_details {
	msg=$1
	echo "  ${msg}"
}

function echo_done {
	msg=$1
	color_echo "${GREEN}" "  ${msg}"
}

function validate_required_input {
	key=$1
	value=$2
	if [ -z "${value}" ] ; then
		echo_fail "[!] Missing required input: ${key}"
	fi
}

function validate_required_input_with_options {
	key=$1
	value=$2
	options=$3

	validate_required_input "${key}" "${value}"

	found="0"
	for option in "${options[@]}" ; do
		if [ "${option}" == "${value}" ] ; then
			found="1"
		fi
	done

	if [ "${found}" == "0" ] ; then
		echo_fail "Invalid input: (${key}) value: (${value}), valid options: ($( IFS=$", "; echo "${options[*]}" ))"
	fi
}

#=======================================
# Main
#=======================================

#
# Validate parameters
echo_info "Configs:"
echo_details "* source_path: $source_path"
echo_details "* appledoc_conf: $appledoc_conf"
echo_details "* readme_path: $readme_path"
echo_details "* output_file: $output_file"
echo

validate_required_input "source_path" $source_path
validate_required_input "appledoc_conf" $appledoc_conf
validate_required_input "readme_path" $readme_path
validate_required_input "output_file" $output_file

# this expansion is required for paths with ~
#  more information: http://stackoverflow.com/questions/3963716/how-to-manually-expand-a-special-variable-ex-tilde-in-bash
eval expanded_source_path="${source_path}"

output_dir=`dirname $output_file`

if [ ! -d "${source_path}" ]; then
  echo_fail "The source folder doesn't exist at: ${source_path}"
  exit 1
fi

echo_info "Installing appledoc..."
brew install appledoc

BUILD_DIR="./appledoc"

[ -e "$BUILD_DIR" ] || mkdir "$BUILD_DIR"
[ -e "$output_dir" ] || mkdir -p "$output_dir"

README_ARG=" "
if [ ! -z "$readme_path" ]; then
  README_ARG="--index-desc ${readme_path}"
fi

TEMPLATE_DIR="/usr/local/bin/$(dirname $(readlink `which appledoc`))/../Templates"

echo "Generating Appledocs..."
/usr/local/bin/appledoc --print-settings \
                        --output $BUILD_DIR \
                        --exit-threshold 2 \
                        --templates $TEMPLATE_DIR \
                        $README_ARG \
                        $appledoc_conf $source_path
if [ $? -eq 0 ]; then
  echo "Generating documentation archives..."
  zip -rq "$output_file" "$BUILD_DIR/html"
else
  echo "Appledoc encountered an issue."
  exit 1
fi

# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
#  envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
