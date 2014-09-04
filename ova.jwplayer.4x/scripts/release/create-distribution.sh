#!/bin/sh
#
#    create-distribution
#

PRODUCT="ova.jwplayer.4x"
SVN_WORKSPACE="/Users/paulschulz/workspace/ova/lt-svn"
WORKING_DIRECTORY="/Users/paulschulz/temp"
RELEASE_NUMBER=0]1.0.0
COMMIT=false
CLEANUP=false
STARTING_DIRECTORY=`pwd`

echo "Creating a new distribution package - ${PRODUCT}.tar.gz (v${RELEASE_NUMBER}) ..."

echo "Creating the working directory"
cd $WORKING_DIRECTORY
rm -rf ${PRODUCT}.temp
mkdir ${PRODUCT}.temp
cd ${PRODUCT}.temp

echo "Copying files to create distribution"
cp -R ${SVN_WORKSPACE}/trunk/${PRODUCT} .

echo "Making sure there are no .DS_Store or .svn files in the distribution"
find . -name ".DS_Store" -print0 | xargs -t0 rm
rm -rf `find . -type d -name .svn`

echo "Creating the final tar.gz file"
tar cvf ${PRODUCT}.tar ${PRODUCT}
gzip ${PRODUCT}.tar
zip -r ${PRODUCT}.zip ${PRODUCT}
ls -l ${PRODUCT}.*

if ( test $COMMIT )
then
	echo "Committing the new distribution to the SVN repository"
	cp ${PRODUCT}.tar.gz ${SVN_WORKSPACE}/packages/${PRODUCT}
	cp ${PRODUCT}.zip ${SVN_WORKSPACE}/packages/${PRODUCT}
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
