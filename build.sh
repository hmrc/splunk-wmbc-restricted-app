#!/bin/bash -ex
workdir=$(dirname $0)
appdir=$(basename $(pwd $workdir))
appname=${2:-$appdir}
output_folder=${1:-/tmp}
if [[ $3 ]]
then
    version=$3
else
    version=`date +"%Y%m%d_%H%M%S"`_build_${BUILD_NUMBER:-LOCAL}
fi

# if output folder does not exist create as passed
if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

# tidy up any previously built package
rm -rf $output

# copy all files to build dir
mkdir $workdir/$appname
rsync -rlp --exclude="$appname" $workdir/ $workdir/$appname/

# move all files from local dir to default dir except app.conf which needs to be merged
# rsync -aI --exclude="**/app.conf" $workdir/$appname/local/ $workdir/$appname/default/

# add appropriate version to app.conf file
sed -e "s/^version.*$/version = ${version}/" \
        < $workdir/$builddir/$appname/default/app.conf \
        > tmpappconf \
      && mv tmpappconf $workdir/$builddir/$appname/default/app.conf
# rm -rf $workdir/$appname/local

# package
cd $workdir \
  && tar --exclude=.git \
         --exclude=.gitignore \
         --exclude=.version \
         --exclude=build.sh \
         --exclude=publish.sh \
         --exclude=Jenkinsfile \
         --exclude=Makefile \
         --exclude=output \
         --exclude=scripts \
         -czf $output_folder/$appname.tgz $appname \
  && cd -

# tidy up build dir
rm -rf $workdir/$appname

# friendly message
echo "Wrote $output_folder/$appname.tgz"