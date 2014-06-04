#! /bin/bash

# Description: This script compiles and copy the needed for the web application

OpenColor="\033["
Red="1;31m"
Yellow="1;33m"
Green="1;32m"
CloseColor="\033[0m"

# Check function OK
checkOK() {
  if [ $? != 0 ]; then
    echo "${OpenColor}${Red}* ERROR. Exiting...${CloseColor}"
    exit 1
  fi
}

# Configs
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APPDIR="$BUILDDIR/copay-webapp"
ZIPFILE="copay.zip"
VERSION=`cut -d '"' -f2 $BUILDDIR/../version.js`

DOWNLOADDIR="$BUILDDIR/download"
CHROMEDOWNLOADDIR="$DOWNLOADDIR/chrome"
FIREFOXDOWNLOADDIR="$DOWNLOADDIR/firefox"
ZIPFILE="copay.zip"


# Move to the build directory
cd $BUILDDIR

# Create/Clean temp dir
echo "${OpenColor}${Green}* Checking temp dir...${CloseColor}"
if [ -d $APPDIR ]; then
  rm -rf $APPDIR
fi

mkdir -p $APPDIR

# Re-compile copayBundle.js
echo "${OpenColor}${Green}* Generating copay bundle...${CloseColor}"
grunt --target=dev shell
checkOK

# Copy all chrome-extension files
echo "${OpenColor}${Green}* Copying all chrome-extension files...${CloseColor}"
cd $BUILDDIR/..
cp -af {css,font,img,js,lib,sound,config.js,version.js,index.html} $APPDIR
checkOK

# Zipping chrome-extension
echo "${OpenColor}${Green}* Zipping all webapp files...${CloseColor}"
cd $BUILDDIR
zip -r $ZIPFILE "`basename $APPDIR`"
checkOK

mkdir -p $CHROMEDOWNLOADDIR
mkdir -p $FIREFOXDOWNLOADDIR
mv $ZIPFILE $DOWNLOADDIR
cp "$BUILDDIR/index-download-chrome.html" $CHROMEDOWNLOADDIR/index.html
cp "$BUILDDIR/index-download-firefox.html" $FIREFOXDOWNLOADDIR/index.html
cp "$BUILDDIR/index-download.html" $DOWNLOADDIR/index.html

echo "${OpenColor}${Yellow}\nAwesome! We have a brand new Webapp, enjoy it!${CloseColor}"
