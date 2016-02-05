# default tag that is used if not specified otherwise
tag=cuda7.0-cudnn3
gpu=0


# only change if new tags are added or existing tags are removed
alltags=ubuntu-14.04 cuda6.5 cuda7.0-cudnn2 cuda7.0-cudnn3 cuda7.0-cudnn4
ldapbaseimages=ubuntu:14.04 nvidia/cuda:6.5-devel nvidia/cuda:7.0-cudnn2-devel nvidia/cuda:7.0-cudnn3-devel nvidia/cuda:7.0-cudnn4-devel


# generic commands that apply to all images
# -----------------------------------------

# builds the full stack of images for the tag
#
# parameters:
# - optional: tag
build-all:
	docker build -t bethgelab/xserver:$(tag) docker-xserver/$(tag)/
	docker build -t bethgelab/jupyter-notebook:$(tag) docker-jupyter-notebook/$(tag)/
	docker build -t bethgelab/jupyter-scipyserver:$(tag) docker-jupyter-scipyserver/$(tag)/
	docker build -t bethgelab/jupyter-deeplearning:$(tag) docker-jupyter-deeplearning/$(tag)/

# clone all images (repositories)
clone-all:
	git clone git@github.com:bethgelab/docker-xserver.git
	git clone git@github.com:bethgelab/docker-jupyter-notebook.git
	git clone git@github.com:bethgelab/docker-jupyter-scipyserver.git
	git clone git@github.com:bethgelab/docker-jupyter-deeplearning.git

# clone all images (repositories) using https
clone-all-https:
	git clone https://github.com/bethgelab/docker-xserver.git
	git clone https://github.com/bethgelab/docker-jupyter-notebook.git
	git clone https://github.com/bethgelab/docker-jupyter-scipyserver.git
	git clone https://github.com/bethgelab/docker-jupyter-deeplearning.git

# update all images (repositories)
pull-github-all:
	make git-command command=pull

# update all images (repositories)
status-all:
	make git-command command=status

# run a git command in every repository
#
# parameter:
# - required: command
git-command:
	cd docker-xserver && git $(command)
	cd docker-jupyter-notebook && git $(command)
	cd docker-jupyter-scipyserver && git $(command)
	cd docker-jupyter-deeplearning && git $(command)

# opens file in vim and syncs across tags
#
# parameters:
# - required: image, file
# - optional: tag
vim-image:
	vim $(image)/$(tag)/$(file)
	make sync-file image=$(image) file=$(file) tag=$(tag)

# opens Dockerfile in vim, syncs across tags and sets correct base image
#
# parameters:
# - required: image, baseimage
# - optional: tag
docker-image:
	vim $(image)/$(tag)/Dockerfile
	make sync-file image=$(image) file=Dockerfile tag=$(tag)
	make setbase-dockerfile image=$(image) baseimage=$(baseimage)

# sync a file from tag directory to all other tags
#
# parameters:
# - required: image, file
# - optional: tag
sync-file:
	for atag in $(alltags) ; do \
	  cp $(image)/$(tag)/$(file) $(image)/$$atag/$(file)  2>/dev/null || : ; \
	done

# set the correct base images for all tags
#
# parameters:
# - required: image, baseimage
setbase-dockerfile:
	for atag in $(alltags) ; do \
	  sed -i '1 s%^.*%FROM bethgelab/$(baseimage):'$$atag'%' $(image)/$$atag/Dockerfile ; \
	done


# image-specific commands
# -----------------------

# build indiviual images
#
# parameters:
# - optional: tag
build-xserver:
	docker build -t bethgelab/xserver:$(tag) docker-xserver/$(tag)/
build-notebook:
	docker build -t bethgelab/jupyter-notebook:$(tag) docker-jupyter-notebook/$(tag)/
build-scipyserver:
	docker build -t bethgelab/jupyter-scipyserver:$(tag) docker-jupyter-scipyserver/$(tag)/
build-deeplearning:
	docker build -t bethgelab/jupyter-deeplearning:$(tag) docker-jupyter-deeplearning/$(tag)/

# opens Dockerfile in vim, syncs across tags and sets correct base image
#
# parameters:
# - optional: tag
docker-xserver:
	make vim-image image=xserver file=Dockerfile
	python utils/set_ldap_baseimages.py '$(alltags)' '$(ldapbaseimages)'
docker-notebook:
	make docker-image image=jupyter-notebook baseimage=xserver tag=$(tag)
docker-scipyserver:
	make docker-image image=jupyter-scipyserver baseimage=jupyter-notebook
docker-deeplearning:
	make docker-image image=jupyter-deeplearning baseimage=jupyter-scipyserver

# opens any file (use file=... as argument) in vim and syncs across tags after closing
#
# parameters:
# - required: file
# - optional: tag
vim-xserver:
	make vim-image image=xserver file=$(file) tag=$(tag)
vim-notebook:
	make vim-image image=jupyter-notebook file=$(file) tag=$(tag)
vim-scipyserver:
	make vim-image image=jupyter-scipyserver file=$(file) tag=$(tag)
vim-deeplearning:
	make vim-image image=jupyter-deeplearning file=$(file) tag=$(tag)

# run interactive (-it --rm)
#
# parameters:
# - optional: tag
# - optional: gpu
interactive-xserver:
	GPU=$(gpu) ./agmb-docker run -it --rm bethgelab/xserver:$(tag)
interactive-notebook:
	GPU=$(gpu) ./agmb-docker run -it --rm bethgelab/jupyter-notebook:$(tag)
interactive-scipyserver:
	GPU=$(gpu) ./agmb-docker run -it --rm bethgelab/jupyter-scipyserver:$(tag)
interactive-deeplearning:
	GPU=$(gpu) ./agmb-docker run -it --rm bethgelab/jupyter-deeplearning:$(tag)

# run as daemon (-d)
#
# parameters:
# - optional: tag
# - optional: gpu
daemon-xserver:
	GPU=$(gpu) ./agmb-docker run -d bethgelab/xserver:$(tag)
daemon-notebook:
	GPU=$(gpu) ./agmb-docker run -d bethgelab/jupyter-notebook:$(tag)
daemon-scipyserver:
	GPU=$(gpu) ./agmb-docker run -d bethgelab/jupyter-scipyserver:$(tag)
daemon-deeplearning:
	GPU=$(gpu) ./agmb-docker run -d bethgelab/jupyter-deeplearning:$(tag)

