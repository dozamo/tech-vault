---
up: "[[Container Platform]]"
related:
  - "[[Add Container Images]]"
  - "[[Access to Container Services]]"
note_type: note
library_type: container-platform
desc: ""
tags: [CLI, linux-cli, container-platform, LFCS, Docker]
---

## Add container images

```bash
# show images
docker images

# start a container and install nginx
docker run ubuntu /bin/bash -c "apt-get update; apt-get -y install nginx"

docker ps --all

docker ps -a|head -2

# add the image
docker commit 657fdcd1c365 $(hostname)/001-ubuntu-nginx

docker images

# generate a container from the new image and execute [which] to make sure nginx exists
docker run $(hostname)/001-ubuntu-nginx /usr/bin/which nginx

```
