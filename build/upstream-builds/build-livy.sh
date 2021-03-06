#!/bin/bash
#
# This script supports two use cases:
#
#   Build Livy corresponding to specific PNDA version
#       Pass "PNDA" as first parameter
#       Pass platform-salt branch or tag as second parameter (e.g. release/3.2)
#   Build specific Livy version
#       Pass "UPSTREAM" as first parameter
#       Pass upstream branch or tag as second parameter (e.g. 1.2.3.4)
#

MODE=${1}
ARG=${2}

function error {
    echo "Not Found"
    echo "Please run the build dependency installer script"
    exit -1
}

function build_error {
    echo "Build error"
    echo "Please determine the reason for the error, correct and re-run"
    exit -1
}

echo -n "shyaml: "
if [[ -z $(which shyaml) ]]; then
    error
else
    echo "OK"
fi

if [[ ${MODE} == "PNDA" ]]; then
    LV_VERSION=$(wget -qO- https://raw.githubusercontent.com/pndaproject/platform-salt/${ARG}/pillar/services.sls | shyaml get-value livy.release_version)
elif [[ ${MODE} == "UPSTREAM" ]]; then
    LV_VERSION=${ARG}
fi

wget https://github.com/cloudera/livy/archive/v${LV_VERSION}.tar.gz
[[ $? -ne 0 ]] && error
tar xzf v${LV_VERSION}.tar.gz

mkdir -p pnda-build
cd livy-${LV_VERSION}
mvn -e package -DskipTests
[[ $? -ne 0 ]] && build_error

cd ..
tar czf livy-${LV_VERSION}.tar.gz livy-${LV_VERSION}
mv livy-${LV_VERSION}.tar.gz pnda-build/
sha512sum pnda-build/livy-${LV_VERSION}.tar.gz > pnda-build/livy-${LV_VERSION}.tar.gz.sha512.txt
