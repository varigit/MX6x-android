#!/bin/bash
#
# install
#
# This script must be run from the Android main directory.
#
# Variscite patches for Android 16.0.0_2.0.0

set -e
#set -x

SCRIPT_NAME=${0##*/}
readonly SCRIPT_VERSION="0.2"

#### global variables ####
readonly ABSOLUTE_FILENAME=$(readlink -e "$0")
readonly ABSOLUTE_DIRECTORY=$(dirname ${ABSOLUTE_FILENAME})
readonly SCRIPT_POINT=${ABSOLUTE_DIRECTORY}
readonly ANDROID_DIR=$(readlink -e "${SCRIPT_POINT}/../../..")

## git variables
readonly _EXTPARAM_BRANCH="android-16.0.0_2.0.0-var01"

## dirs ##
readonly VARISCITE_PATCHS_DIR="${SCRIPT_POINT}/platform"

# print error message
# p1 - printing string
function pr_error() {
	echo ${2} "E: $1"
}

# print warning message
# p1 - printing string
function pr_warning() {
	echo ${2} "W: $1"
}

# print info message
# p1 - printing string
function pr_info() {
	echo ${2} "I: $1"
}

# check that every patch of a git either applies or is already applied
# p1 - git folder
# p2 - patches folder
function check_patches()
{
	local _patch

	for _patch in ${2}/*.patch; do
		if git -C "${1}" apply --reverse --check "${_patch}" 2>/dev/null; then
			continue
		elif ! git -C "${1}" apply --check "${_patch}"; then
			pr_error "Conflicting patch: ${_patch}"
			exit 1
		fi
	done
}

############### main code ##############
pr_info "Script version ${SCRIPT_VERSION}"

if [[ ! -f "${ANDROID_DIR}/build/envsetup.sh" ]]; then
	pr_error "Cannot locate the Android source root: ${ANDROID_DIR}"
	exit 1
fi

cd ${VARISCITE_PATCHS_DIR} > /dev/null
git_array=$(find * -type d -name '*.git' | sort)
cd - > /dev/null

# Validate every git before changing any of them.
for _ddd in ${git_array}
do
	_git_p=${_ddd%.git}
	if [[ -n $(git -C "${ANDROID_DIR}/${_git_p}" status --porcelain --untracked-files=no) ]]; then
		pr_error "\"${_git_p}/\" has local changes; commit or discard them first"
		exit 1
	fi
	check_patches "${ANDROID_DIR}/${_git_p}" "${VARISCITE_PATCHS_DIR}/${_ddd}"
done

pr_info "###########################"
pr_info "# Apply framework patches #"
pr_info "###########################"
for _ddd in ${git_array}
do
	_git_p=${_ddd%.git}
	cd ${ANDROID_DIR}/${_git_p}/ > /dev/null

	if [[ `git branch --list $_EXTPARAM_BRANCH` ]] ; then
		git checkout ${_EXTPARAM_BRANCH} || {
			pr_warning "Branch ${_EXTPARAM_BRANCH} checkout failed!"
		};
	else
		git checkout -b ${_EXTPARAM_BRANCH} || {
			pr_warning "Branch ${_EXTPARAM_BRANCH} is present!"
		};
	fi

	pr_info "Apply patches for this git: \"${_git_p}/\""
	for _patch in ${VARISCITE_PATCHS_DIR}/${_ddd}/*.patch; do
		if git apply --reverse --check "${_patch}" 2>/dev/null; then
			pr_info "Skipping already applied: $(basename ${_patch})"
		else
			git am "${_patch}"
		fi
	done

	cd - > /dev/null
done

pr_info "#####################"
pr_info "# Done             #"
pr_info "#####################"

exit 0
