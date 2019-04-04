docker pull headmelted/archie
docker run -it --security-opt apparmor:unconfined --cap-add SYS_ADMIN -v %cd%/archie:/archie headmelted/archie /bin/bash -c "cd /kitchen && export ARCHIE_GIT_ENDPOINT=""https://github.com/Microsoft/vscode.git\""; steps/cook.sh armhf get patch build package";
