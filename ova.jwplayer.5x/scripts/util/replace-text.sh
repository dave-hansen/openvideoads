#!/bin/sh

# Get list of config and html files to be replaced
file_list=`find . \( -name "*.xml" -o -name "*.html" \) -type f`

# Perform Substitution
for fn in $file_list
do
   if ( test $fn != ./`basename $0` )
   then
      ffnt="$fn.temp"
      strippedFn=`echo $fn | sed '/index.html/!d;'`
      if [ "$strippedFn" = "" ]
      then
         echo "Processing $fn .. "
         sed "s/${1}/${2}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
      fi
   fi
done

echo "Done."