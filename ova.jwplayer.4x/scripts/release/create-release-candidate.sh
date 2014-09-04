#!/bin/sh
#
#    create-release-candidate <version> <commit> <cleanup>
#

PRODUCT="ova.jwplayer.4x"
SVN_WORKSPACE="/Users/paulschulz/workspace/ova/lt-svn"
WORKING_DIRECTORY="/Users/paulschulz/temp"
RELEASE_NUMBER=0.0.0
COMMIT=false
CLEANUP=false
STARTING_DIRECTORY=`pwd`

echo "Creating a new release candidate package - ${PRODUCT}.tar.gz (v${RELEASE_NUMBER}) ..."

echo "Creating the working directory"
cd $WORKING_DIRECTORY
rm -rf ${PRODUCT}.temp
mkdir ${PRODUCT}.temp
cd ${PRODUCT}.temp

echo "Copying files to create the release candidate"
cp -R ${SVN_WORKSPACE}/trunk/${PRODUCT} .

echo "Making sure there are no .DS_Store or .svn files in the release candidate"
find . -name ".DS_Store" -print0 | xargs -t0 rm
rm -rf `find . -type d -name .svn`

echo "Creating the final tar.gz file"
tar cvf ${PRODUCT}-rc.tar ${PRODUCT}
gzip ${PRODUCT}-rc.tar
ls -l ${PRODUCT}-rc.tar.gz

if ( test $COMMIT )
then
	echo "Committing the new release candidate to the SVN repository"
	cp ${PRODUCT}-rc.tar.gz ${SVN_WORKSPACE}/packages/${PRODUCT}
	cd ${SVN_WORKSPACE}/packages/${PRODUCT}
#	svn commit -m "Release package v${RELEASE_NUMBER}"
fi

if ( test $CLEANUP )
then
	echo "Cleaning up the working directory"
	cd $WORKING_DIRECTORY
	rm -rf ${PRODUCT}.temp
fi

cd $STARTING_DIRECTORY
echo "Done."
