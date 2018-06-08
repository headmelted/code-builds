#!/bin/sh

clear;
echo "
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
                          _   __ _             _             ___          _
 /\   /(_)___ _   _  __ _| | / _\ |_ _   _  __| (_) ___     / __\___   __| | ___ 
 \ \ / / / __| | | |/ _\` | | \ \| __| | | |/ _\` | |/ _ \   / /  / _ \ / _\` |/ _ \\
  \ V /| \__ \ |_| | (_| | | _\ \ |_| |_| | (_| | | (_) | / /__| (_) | (_| |  __/
   \_/ |_|___/\__,_|\__,_|_| \__/\__|\__,_|\__,_|_|\___/  \____/\___/ \__,_|\___|
                                               
                                  for Chromebooks          
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

                       PLEASE READ THIS INFORMATION CAREFULLY           

This tool will guide you through setting up your Chromebook for Visual Studio Code.

Code requires a Linux environment to run, so we'll need to install a Ubuntu 16.04
(Xenial Xerus) environment first. Then we'll install git, and some helpers to make
using Code as smooth as possible on your Chromebook, including a launch helper that
will start Code in it's own window 'code'.

During the installation of the Linux chroot, crouton will ask several questions to
ensure you are aware of the changes it is making.

PLEASE READ ALL OF THE QUESTIONS YOU ARE ASKED CAREFULLY BEFORE ANSWERING.

DISCLAIMER:

THIS SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THIS 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THIS SOFTWARE.


";

printf "Install now? (y/n): "
read install_now;
if [ $install_now != "y" ]; then
  echo "No problem!  Please just run me again whenever you wish to install Visual Studio Code.";
  exit;
fi;

cd ~/Downloads;

echo "Great! Let's get to it then.";
echo "Downloading crouton...";
wget https://goo.gl/fd3zc -O crouton;
echo "crouton downloaded.";

echo "Detecting architecture...";
MACHINE_MTYPE="$(uname -m)";
ARCH="${MACHINE_MTYPE}";
REPOSITORY_NAME="headmelted";

if [ "$ARCH" = "armv7l" ]; then ARCH="armhf"; fi;
if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "i386"]; then REPOSITORY_NAME="Microsoft"; fi;

echo "Architecture detected as ${ARCH}...";

echo "Preparing xenial chroot with XIWI (you will be prompted for a root password.  You can use crouton to encrypt the chroot later if you wish.)..."
chmod +x ./crouton;
if [ "$ARCH" = "arm64" ]; then
  echo "Chroot will be created as armhf. This will be changed later when Electron introduces 64-bit ARM support...";
  sudo sh ./crouton -t xiwi -a armhf -n code-oss-chroot;
else
  sudo sh ./crouton -t xiwi -n code-oss-chroot;
fi;

if [ $? -eq 0 ]; then
  echo "Crouton install script complete.";
else
  echo "Crouton install script failed.";
  exit 1;
fi;

echo "Entering chroot to install Visual Studio Code, you may need to enter the chronos password if you've previously changed it, and/or the password you entered above for the chroot!";
sudo enter-chroot -n code-oss-chroot sudo -S sh -c "$( curl -s https://code.headmelted.com/installers/apt.sh )";
if [ $? -eq 0 ]; then
  echo "APT install script complete.";
else
  echo "APT install script failed.";
  exit 1;
fi;

echo "Removing any existing 'code' alias from ~/.bashrc...";
if [ -e ~/.bashrc ]; then sudo sed -i.bak '/alias code=/d' ~/.bashrc; fi;
echo "Done!"

CODE_EXECUTABLE_NAME="";
if [ "${REPOSITORY_NAME}" = "headmelted" ]; then
  CODE_EXECUTABLE_NAME="code-oss";
else
  CODE_EXECUTABLE_NAME="code-insiders";
fi;

echo "Removing existing 'code' aliases...";
sudo sed -i '/^alias code/d' ~/.bashrc;
echo "Done!";

echo "Aliasing 'code'..."
sudo echo "alias code=\"sudo startxiwi -n code-oss-chroot ${CODE_EXECUTABLE_NAME}\"" >> ~/.bashrc;
echo "Done!"

echo "Reloading .bashrc...";
. ~/.bashrc;
echo "Done!";

echo "

To run Visual Studio Code from now on perform the following steps:

1) Press Ctrl+Alt+T on your keyboard to open a crosh shell.
2) Type (without the quotes!) \"shell\" and press return.
3) Type (without the quotes!) \"code\" and press return.

";

exit;

