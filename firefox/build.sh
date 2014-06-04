#! /bin/bash

# Description: This script compiles and copy the needed files to later package the application for Firefox

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
APPDIR="$BUILDDIR/firefox-addon"
ZIPFILE="copay-firefox-addon.zip"
VERSION=`cut -d '"' -f2 $BUILDDIR/../version.js`

# Move to the build directory
cd $BUILDDIR

# Create/Clean temp dir
echo "${OpenColor}${Green}* Checking temp dir...${CloseColor}"
if [ -d $APPDIR ]; then
  rm -rf $APPDIR
fi

mkdir -p "$APPDIR/data"

# Re-compile copayBundle.js
echo "${OpenColor}${Green}* Generating copay bundle...${CloseColor}"
grunt --target=dev shell
checkOK

# Copy all chrome-extension files
echo "${OpenColor}${Green}* Copying all firefox-addon files...${CloseColor}"
sed "s/APP_VERSION/$VERSION/g" package.json > $APPDIR/package.json
checkOK

cd $BUILDDIR/..
cp -af {css,font,img,js,lib,sound,config.js,version.js,index.html,./popup.html} "$APPDIR/data"
cp -af "$BUILDDIR/lib" $APPDIR
checkOK

echo "${OpenColor}${Yellow}\nAwesome! We have a brand new Firefox Addon, enjoy it!${CloseColor}"
