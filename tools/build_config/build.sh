#!/usr/bin/env bash

set -o errexit  # exit early on any error
set -o nounset  # raise error using unset variables

readonly FALSE=0
readonly TRUE=1
readonly CMAKE_GENERATOR="Unix Makefiles"
# The Horace root directory is two levels above this script
readonly HORACE_ROOT="$(realpath "$(dirname "$0")"/../..)"
# The Matlab root directory is one level above Matlab/bin which contains the
# matlab executable. The Matlab on the path will likely be a symlink so we need
# to resolve it with `readlink`
readonly MATLAB_ROOT="$(realpath $(dirname "$(readlink -f "$(which matlab)")")/..)"
readonly MAX_CTEST_SUCCESS_OUTPUT_LENGTH=10000 # 10 kilobytes

# shellcheck source=./bash_helpers.sh
. "${HORACE_ROOT}/tools/build_config/bash_helpers.sh"

function print_package_versions() {
  cmake --version | head -n 1
  echo "Matlab: ${MATLAB_ROOT}"
  g++ --version | head -n 1
  echo
}

function run_configure() {
  local build_dir=$1
  local build_config=$2
  local build_tests=$3
  local matlab_release=$4
  local cmake_flags="${5-}"  # Default value is empty string

  cmake_cmd="cmake ${HORACE_ROOT}"
  cmake_cmd+=" -G \"${CMAKE_GENERATOR}\""
  cmake_cmd+=" -DMatlab_ROOT_DIR=${MATLAB_ROOT}"
  cmake_cmd+=" -DCMAKE_BUILD_TYPE=${build_config}"
  cmake_cmd+=" -DBUILD_TESTS=${build_tests}"
  cmake_cmd+=" -DMatlab_RELEASE=${matlab_release}"
  cmake_cmd+=" ${cmake_flags}"

  echo -e "\nRunning CMake configure step..."
  echo_and_run "cd ${build_dir}"
  echo_and_run "${cmake_cmd}"
}

function run_build() {
  local build_dir=$1

  echo -e "\nRunning build step..."
  build_cmd="cmake --build ${build_dir}"
  echo_and_run "${build_cmd}"
}

function run_tests() {
  local build_dir=$1

  echo -e "\nRunning test step..."
  echo_and_run "cd ${build_dir}"
  test_cmd="ctest -T Test --no-compress-output"
  test_cmd+=" --output-on-failure"
  test_cmd+=" --test-output-size-passed ${MAX_CTEST_SUCCESS_OUTPUT_LENGTH}"
  echo_and_run "${test_cmd}"
}

function run_package() {
  echo -e "\nRunning package step..."
  echo_and_run "cd ${build_dir}"
  echo_and_run "cpack -G TGZ"
}

function main() {
  # set default parameter values
  local build=$FALSE
  local test=$FALSE
  local package=$FALSE
  local print_versions=$FALSE
  local build_tests="ON"
  local build_config='Release'
  local build_dir="${HORACE_ROOT}/build"
  local matlab_release=""
  local cmake_flags=""

  # parse command line args
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        # flags
        -b|--build) build=$TRUE; shift ;;
        -t|--test) test=$TRUE; shift ;;
        -p|--package) package=$TRUE; shift ;;
        -v|--print_versions) print_versions=$TRUE; shift ;;
        # options
        -X|--build_tests) build_tests="$2"; shift; shift ;;
        -C|--build_config) build_config="$2"; shift; shift ;;
        -O|--build_dir) build_dir="$(realpath $2)"; shift; shift ;;
        -M|--matlab_release) matlab_release="$2"; shift; shift ;;
        -F|--cmake_flags) cmake_flags="$2"; shift; shift ;;
        *) echo "Unrecognised argument '$key'"; exit 1 ;;
    esac
  done

  if ((print_versions)); then
    print_package_versions
  fi

  if ((build)); then
    warning_msg="Warning: Build directory ${build_dir} already exists.\n\
        This may not be a clean build."
    echo_and_run "mkdir ${build_dir}" || warning "${warning_msg}"
    run_configure "${build_dir}" "${build_config}" "${build_tests}" "${matlab_release}" "${cmake_flags}"
    run_build "${build_dir}"
  fi

  if ((test)); then
    run_tests ${build_dir}
  fi

  if ((package)); then
    run_package
  fi
}

main "$@"
