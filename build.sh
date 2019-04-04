#!/bin/bash
set -e;

echo "Installing NVM and NodeJS";
. ./setup_nvm.sh;

echo "Retrieving latest Visual Studio Code sources into [code]";
git clone "https://github.com/Microsoft/vscode.git" code;
  
echo "Setting current owner as owner of code folder";
chown ${USER:=$(/usr/bin/id -run)}:$USER -R code;

echo "Synchronizing overlays folder";
rsync -avh ./overlays/ ./code/;

echo "Entering code directory";
cd code;

extra_links="-I$compiler_root_directory/usr/include/libsecret-1 -I$compiler_root_directory/usr/include/glib-2.0 -I$compiler_root_directory/usr/lib/${ARCHIE_HEADERS_GNU_TRIPLET}/glib-2.0/include";
export CC="$CC $extra_links"
export CXX="$CXX $extra_links"

CHILD_CONCURRENCY=1 yarn;

echo "Running hygiene";
npm run gulp -- hygiene;

echo "Running monaco-compile-check";
npm run monaco-compile-check;

#echo "Executing strict-null-check";
#npm run strict-null-check;

echo "Installing built-in extensions";
node build/lib/builtInExtensions.js;

echo "Compiling VS Code for $ARCHIE_ELECTRON_ARCH";
npm run gulp -- vscode-linux-$ARCHIE_ELECTRON_ARCH-min --unsafe-perm;

echo "Executing compile";
yarn --verbose compile;

echo "Executing download-builtin-extensions";
yarn --verbose download-builtin-extensions;

echo "Starting vscode-linux-$ARCHIE_ELECTRON_ARCH-build-deb";
yarn run gulp vscode-linux-$ARCHIE_ELECTRON_ARCH-build-deb;

echo "Starting vscode-linux-$ARCHIE_ELECTRON_ARCH-build-rpm";
yarn run gulp vscode-linux-$ARCHIE_ELECTRON_ARCH-build-rpm;

echo "Leaving code directory";
cd ..;

echo "Creating output directory";
mkdir output;

echo "Moving deb packages for release";
mv ./code/.build/linux/deb/$ARCHIE_ARCH/deb/*.deb /root/output;

echo "Moving rpm packages for release";
mv ./code/.build/linux/rpm/$ARCHIE_RPM_ARCH/rpmbuild/RPMS/$ARCHIE_RPM_ARCH/*.rpm /root/output;

echo "Extracting deb archive";
dpkg -x /root/output/*.deb output/extracted;

cd output/extracted;

echo "Binary components of output --------------------------------------------------"
find . -type f -exec file {} ";" | grep ELF
echo "------------------------------------------------------------------------------"
