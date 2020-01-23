#!/bin/bash    

download_location=https://excellmedia.dl.sourceforge.net/project/geonetwork/GeoNetwork_opensource
release=$1
download_url=${download_location}/v${release}/geonetwork.war
included_artifacts='common core domain'

# Create temporary working directory

WORK_DIR=`mktemp -d`

if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

# deletes the temp directory
function cleanup {      
  rm -rf "$WORK_DIR"
  echo "Deleted temp working directory $WORK_DIR"
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

# Download war and unzip

curl -o $WORK_DIR/geonetwork.war "$download_url"
unzip -d $WORK_DIR/geonetwork $WORK_DIR/geonetwork.war

# Set groupId, artifactId, version for war from maven properties file

properties_file=`find $WORK_DIR/geonetwork/META-INF/maven -name pom.properties`

groupId=`grep groupId $properties_file | cut -d'=' -f2`
artifactId=`grep artifactId $properties_file | cut -d'=' -f2`
version=`grep version $properties_file | cut -d'=' -f2`

# deploy war to s3 maven repo

# This is how you use maven to deploy directly to an s3 maven repo
# requires access keys or The Amazon EC2 Instance Metadata Service
# and the acompanying pom.xml file
#
# See https://github.com/spring-attic/aws-maven

#mvn deploy:deploy-file -Dfile=$WORK_DIR/geonetwork.war \
# -DgroupId=${groupId} -DartifactId=${artifactId} -Dversion=${version} -DgeneratePom=true \
# -Durl=s3://content.dev.aodn.org.au
#
# deploy included artifacts to s3 maven repo
#
#for artifactId in $included_artifacts; do
#    filename=${artifactId}-${version}.jar
#    path=`find $WORK_DIR/geonetwork -name ${filename}`
#    mvn deploy:deploy-file -Dfile="${path}" \
#     -DgroupId=${groupId} -DartifactId=${artifactId} -Dversion=${version} -DgeneratePom=true \
#     -Durl=s3://content.dev.aodn.org.au
#done

# Or as I'm currently doing by deploying to a local directory and copying up to s3

mvn deploy:deploy-file -Dfile=$WORK_DIR/geonetwork.war \
 -DgroupId=${groupId} -DartifactId=${artifactId} -Dversion=${version} -DgeneratePom=true \
 -Durl=file://$WORK_DIR/repo

 deploy included artifacts to s3 maven repo

for artifactId in $included_artifacts; do
    filename=${artifactId}-${version}.jar
    path=`find $WORK_DIR/geonetwork -name ${filename}`
    mvn deploy:deploy-file -Dfile="${path}" \
     -DgroupId=${groupId} -DartifactId=${artifactId} -Dversion=${version} -DgeneratePom=true \
     -Durl=file://$WORK_DIR/repo
done

aws s3 cp --recursive $WORK_DIR/repo s3://content.dev.aodn.org.au/repo/maven

