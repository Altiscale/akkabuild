#!/bin/bash -x

cd ${WORKSPACE}

echo "ok - $(whoami) user is going to build the project"
echo "ok - fpm is located at $(which fpm)"
echo "ok - PATH=$PATH"
echo "ok - BUILD_BRANCH=$BUILD_BRANCH"
echo "ok - PACKAGE_BRANCH=$PACKAGE_BRANCH"

ret=0
export DATE_STRING=${DATE_STRING:-$(date -u +%Y%m%d%H%M)}
INSTALL_DIR=${WORKSPACE}/install-dir-${DATE_STRING}
RPM_DIR=${WORKSPACE}/rpm-dir-${DATE_STRING}
pushd ${WORKSPACE}

# pushd ${WORKSPACE}/akka
# sbt package
# ret=$?

# This is a hack to just package the JAR before we can build it correctly
# hack_target should exist already with the JARs we need
export RPM_NAME=`echo com.typesafe.akka-actor-${BUILD_BRANCH}`
export RPM_DESCRIPTION="com.typesafe.akka akka-actor library ${BUILD_BRANCH}"

##################
# Packaging  RPM #
##################
export RPM_BUILD_DIR="${INSTALL_DIR}/usr/sap/spark/controller/"
# Generate RPM based on where spark artifacts are placed from previous steps
rm -rf "${RPM_BUILD_DIR}"
mkdir --mode=0755 -p "${RPM_BUILD_DIR}"

# com.typesafe.akka-actor_2.1X-*.jar are a custom name we defined for oursevles
# to distinguish their Scala version's, etc. when we download them from Maven
# and these are NOT built from source.
pushd hack_target
if [[ "$BUILD_BRANCH" == *_2.10 ]] ; then
  mkdir --mode=0755 -p "${RPM_BUILD_DIR}/lib"
  cp -rp com.typesafe.akka-actor_2.10-*.jar $RPM_BUILD_DIR/lib/
elif [[ "$BUILD_BRANCH" == *_2.11 ]] ; then
  mkdir --mode=0755 -p "${RPM_BUILD_DIR}/lib_2.11"
  cp -rp com.typesafe.akka-actor_2.11-*.jar $RPM_BUILD_DIR/lib_2.11/
else
  echo "fatal - unsupported version for $BUILD_BRANCH, can't produce RPM, quitting!"
  exit -1
fi
popd
mkdir -p "${RPM_BUILD_DIR}/licenses"
cp LICENSE "${RPM_BUILD_DIR}/licenses/LICENSE-${RPM_NAME}"

mkdir -p ${RPM_DIR}
pushd ${RPM_DIR}
fpm --verbose \
--maintainer andrew.lee02@sap.com \
--vendor SAP \
--provides ${RPM_NAME} \
--description "$(printf "${RPM_DESCRIPTION}")" \
--replaces ${RPM_NAME} \
--url "https://github.com/Altiscale/akka" \
--license "Proprietary" \
--epoch 1 \
--rpm-os linux \
--architecture all \
--category "Development/Libraries" \
-s dir \
-t rpm \
-n ${RPM_NAME} \
-v ${BUILD_BRANCH} \
--iteration ${DATE_STRING} \
--rpm-user root \
--rpm-group root \
--rpm-auto-add-directories \
-C ${INSTALL_DIR} \
usr

if [ $? -ne 0 ] ; then
	echo "FATAL: scala-akka rpm build fail!"
	popd
	exit -1
fi
popd

exit 0
