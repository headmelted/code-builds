#!/bin/sh

#check for root priv
if [ "$(id -u)" != "0" ]; then
	echo "This installation script must be executed as root (i.e. run via sudo). Exiting" >&2
	exit 1
fi

echo "Detecting architecture...";
MACHINE_MTYPE="$(uname -m)";
ARCH="${MACHINE_MTYPE}";
REPO_VENDOR="headmelted";
DEPENDENCIES=""

echo "Updating APT cache..."
if apt-get update -yq; then
  echo "Update complete.";
else
  echo "Update failed.";
  exit 1;
fi;

#test what dependencies need to be installed
test -f "/usr/share/doc/apt-transport-https/copyright" || DEPENDENCIES="${DEPENDENCIES} apt-transport-https"
sudo command -v update-ca-certificates >/dev/null 2>&1 || DEPENDENCIES="${DEPENDENCIES} ca-certificates"
command -v curl >/dev/null 2>&1 || DEPENDENCIES="${DEPENDENCIES} curl"
command -v git >/dev/null 2>&1 || DEPENDENCIES="${DEPENDENCIES} git"
command -v gpg-agent >/dev/null 2>&1 || DEPENDENCIES="${DEPENDENCIES} gnupg-agent"

if [ "X${DEPENDENCIES}" != "X" ]; then
  echo "Installing dependencies: ${DEPENDENCIES}" >&2
  apt-get -f -qq -y install "${DEPENDENCIES}" >/dev/null 2>&1
fi

if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "i386" ]; then REPO_VENDOR="microsoft"; fi;

echo "Architecture detected as $ARCH...";

if [ "${REPO_VENDOR}" = "headmelted" ]; then
  gpg_key=https://packagecloud.io/headmelted/codebuilds/gpgkey;
  repo_name="stretch";
  repo_entry="deb https://packagecloud.io/headmelted/codebuilds/debian/ ${repo_name} main";
  code_executable_name="code-oss";
else
  gpg_key=https://packages.microsoft.com/keys/microsoft.asc;
  repo_name="stable"
  repo_entry="deb https://packages.microsoft.com/repos/vscode ${repo_name} main";
  code_executable_name="code-insiders";
fi;

echo "Retrieving GPG key [${REPO_VENDOR}] ($gpg_key)...";
curl -fsSL $gpg_key | sudo apt-key add -

echo "Removing any previous entry to headmelted repository";
rm -rf /etc/apt/sources.list.d/headmelted_codebuilds.list;
rm -rf /etc/apt/sources.list.d/codebuilds.list;
  
echo "Installing [${REPO_VENDOR}] repository...";
echo "${repo_entry}" > /etc/apt/sources.list.d/${REPO_VENDOR}_vscode.list;
  
echo "Refreshing APT cache again..."
if apt-get update -yq; then
  echo "Repository install complete.";
else
  echo "Repository install failed.";
  exit 1;
fi;

echo "Installing Visual Studio Code from [${repo_name}]...";
if apt-get install -t ${repo_name} -y ${code_executable_name}; then
  echo "Visual Studio Code install complete.";
else
  echo "Visual Studio Code install failed.";
  exit 1;
fi;

echo "Installing any dependencies that may have been missed...";
if apt-get install -y -f; then
  echo "Missed dependency install complete.";
else
  echo "Missed dependency install failed.";
  exit 1;
fi;

echo "

Installation complete!

You can start code at any time by calling \"${code_executable_name}\" within a terminal.

A shortcut should also now be available in your desktop menus (depending on your distribution).

";
