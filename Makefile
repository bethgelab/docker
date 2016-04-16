# default tag that is used if not specified otherwise
tag=cuda7.0-cudnn4
new_tag=cuda7.5-cudnn4
delete_tag=cuda6.5
gpu=0


# only change if new tags are added or existing tags are removed
alltags=ubuntu-14.04 cuda7.0-cudnn4 cuda7.5-cudnn4
xserverbaseimages=ubuntu:14.04 nvidia/cuda:7.0-cudnn4-devel nvidia/cuda:7.5-cudnn4-devel


# generic commands that apply to all images
# -----------------------------------------

# builds the full stack of images for the tag
#
# parameters:
# - optional: tag
build-all:
	docker build -t bethgelab/xserver:$(tag) docker-xserver/$(tag)/
	docker build -t bethgelab/jupyter-notebook:$(tag) docker-jupyter-notebook/$(tag)/
	docker build -t bethgelab/jupyter-scipyserver-base:$(tag) docker-jupyter-scipyserver-base/$(tag)/
	docker build -t bethgelab/jupyter-scipyserver:$(tag) docker-jupyter-scipyserver/$(tag)/
	docker build -t bethgelab/jupyter-deeplearning:$(tag) docker-jupyter-deeplearning/$(tag)/
	docker build -t bethgelab/jupyter-torch:$(tag) docker-jupyter-torch/$(tag)/

# clone all images (repositories)
clone-all:
	git clone git@github.com:bethgelab/docker-xserver.git
	git clone git@github.com:bethgelab/docker-jupyter-notebook.git
	git clone git@github.com:bethgelab/docker-jupyter-scipyserver-base.git
	git clone git@github.com:bethgelab/docker-jupyter-scipyserver.git
	git clone git@github.com:bethgelab/docker-jupyter-deeplearning.git
	git clone git@github.com:bethgelab/docker-jupyter-torch.git

# clone all images (repositories) using https
clone-all-https:
	git clone https://github.com/bethgelab/docker-xserver.git
	git clone https://github.com/bethgelab/docker-jupyter-notebook.git
	git clone https://github.com/bethgelab/docker-jupyter-scipyserver-base.git
	git clone https://github.com/bethgelab/docker-jupyter-scipyserver.git
	git clone https://github.com/bethgelab/docker-jupyter-deeplearning.git
	git clone https://github.com/bethgelab/docker-jupyter-torch.git

# mostly for debugging: pulls all images for all tags from docker hub
docker-hub-pull-all:
	for atag in $(alltags) ; do \
		docker pull bethgelab/xserver:$$atag ; \
		docker pull bethgelab/jupyter-notebook:$$atag ; \
		docker pull bethgelab/jupyter-scipyserver-base:$$atag ; \
		docker pull bethgelab/jupyter-scipyserver:$$atag ; \
		docker pull bethgelab/jupyter-deeplearning:$$atag ; \
		docker pull bethgelab/jupyter-torch:$$atag ; \
	done

make-tag:
	cp -r docker-xserver/$(tag) docker-xserver/$(new_tag)
	cp -r docker-jupyter-notebook/$(tag) docker-jupyter-notebook/$(new_tag)
	cp -r docker-jupyter-scipyserver-base/$(tag) docker-jupyter-scipyserver-base/$(new_tag)
	cp -r docker-jupyter-scipyserver/$(tag) docker-jupyter-scipyserver/$(new_tag)
	cp -r docker-jupyter-deeplearning/$(tag) docker-jupyter-deeplearning/$(new_tag)
	cp -r docker-jupyter-torch/$(tag) docker-jupyter-torch/$(new_tag)

delete-tag:
	rm -rf docker-xserver/$(delete_tag)
	rm -rf docker-jupyter-notebook/$(delete_tag)
	rm -rf docker-jupyter-scipyserver-base/$(delete_tag)
	rm -rf docker-jupyter-scipyserver/$(delete_tag)
	rm -rf docker-jupyter-deeplearning/$(delete_tag)
	rm -rf docker-jupyter-torch/$(delete_tag)

# update all images (repositories)
pull-github-all:
	make git-all command=pull

# update all images (repositories)
status-all:
	make git-all command=status

# run a git command in every repository
#
# parameter:
# - required: command
git-all:
	cd docker-xserver && git $(command)
	cd docker-jupyter-notebook && git $(command)
	cd docker-jupyter-scipyserver-base && git $(command)
	cd docker-jupyter-scipyserver && git $(command)
	cd docker-jupyter-deeplearning && git $(command)
	cd docker-jupyter-torch && git $(command)

# opens file in vim and syncs across tags
#
# parameters:
# - required: image, file
# - optional: tag
vim-image:
	vim docker-$(image)/$(tag)/$(file)
	make sync-file image=$(image) file=$(file) tag=$(tag)

# opens Dockerfile in vim, syncs across tags and sets correct base image
#
# parameters:
# - required: image, baseimage
# - optional: tag
docker-image:
	vim docker-$(image)/$(tag)/Dockerfile
	make sync-file image=$(image) file=Dockerfile tag=$(tag)
	make setbase-dockerfile image=$(image) baseimage=$(baseimage)

# sync a file from tag directory to all other tags
#
# parameters:
# - required: image, file
# - optional: tag
sync-file:
	for atag in $(alltags) ; do \
	  cp docker-$(image)/$(tag)/$(file) docker-$(image)/$$atag/$(file)  2>/dev/null || : ; \
	done

# set the correct base images for all tags
#
# parameters:
# - required: image, baseimage
setbase-dockerfile:
	for atag in $(alltags) ; do \
	  sed -i '1 s%^.*%FROM bethgelab/$(baseimage):'$$atag'%' docker-$(image)/$$atag/Dockerfile ; \
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
build-scipyserver-base:
	docker build -t bethgelab/jupyter-scipyserver-base:$(tag) docker-jupyter-scipyserver-base/$(tag)/
build-scipyserver:
	docker build -t bethgelab/jupyter-scipyserver:$(tag) docker-jupyter-scipyserver/$(tag)/
build-deeplearning:
	docker build -t bethgelab/jupyter-deeplearning:$(tag) docker-jupyter-deeplearning/$(tag)/
build-torch:
	docker build -t bethgelab/jupyter-torch:$(tag) docker-jupyter-torch/$(tag)/

# opens Dockerfile in vim, syncs across tags and sets correct base image
#
# parameters:
# - optional: tag
.PHONY: docker-xserver
docker-xserver:
	make vim-image image=xserver file=Dockerfile tag=$(tag)
	python utils/set_xserver_baseimage.py '$(alltags)' '$(xserverbaseimages)'
docker-notebook:
	make docker-image image=jupyter-notebook baseimage=xserver tag=$(tag)
docker-scipyserver-base:
	make docker-image image=jupyter-scipyserver-base baseimage=jupyter-notebook
docker-scipyserver:
	make docker-image image=jupyter-scipyserver baseimage=jupyter-scipyserver-base
docker-deeplearning:
	make docker-image image=jupyter-deeplearning baseimage=jupyter-scipyserver
docker-torch:
	make docker-image image=jupyter-torch baseimage=jupyter-deeplearning

# opens any file (use file=... as argument) in vim and syncs across tags after closing
#
# parameters:
# - required: file
# - optional: tag
vim-xserver:
	make vim-image image=xserver file=$(file) tag=$(tag)
vim-notebook:
	make vim-image image=jupyter-notebook file=$(file) tag=$(tag)
vim-scipyserver-base:
	make vim-image image=jupyter-scipyserver-base file=$(file) tag=$(tag)
vim-scipyserver:
	make vim-image image=jupyter-scipyserver file=$(file) tag=$(tag)
vim-deeplearning:
	make vim-image image=jupyter-deeplearning file=$(file) tag=$(tag)
vim-torch:
	make vim-image image=jupyter-torch file=$(file) tag=$(tag)

# run interactive (-it --rm)
#
# parameters:
# - optional: tag
# - optional: gpu
interactive-xserver:
	GPU=$(gpu) ./agmb-docker run -it --rm bethgelab/xserver:$(tag)
interactive-notebook:
	GPU=$(gpu) ./agmb-docker run -it --rm bethgelab/jupyter-notebook:$(tag)
interactive-scipyserver-base:
	GPU=$(gpu) ./agmb-docker run -it --rm bethgelab/jupyter-scipyserver-base:$(tag)
interactive-scipyserver:
	GPU=$(gpu) ./agmb-docker run -it --rm bethgelab/jupyter-scipyserver:$(tag)
interactive-deeplearning:
	GPU=$(gpu) ./agmb-docker run -it --rm bethgelab/jupyter-deeplearning:$(tag)
interactive-torch:
	GPU=$(gpu) ./agmb-docker run -it --rm bethgelab/jupyter-torch:$(tag)

# run as daemon (-d)
#
# parameters:
# - optional: tag
# - optional: gpu
daemon-xserver:
	GPU=$(gpu) ./agmb-docker run -d bethgelab/xserver:$(tag)
daemon-notebook:
	GPU=$(gpu) ./agmb-docker run -d bethgelab/jupyter-notebook:$(tag)
daemon-scipyserver-base:
	GPU=$(gpu) ./agmb-docker run -d bethgelab/jupyter-scipyserver-base:$(tag)
daemon-scipyserver:
	GPU=$(gpu) ./agmb-docker run -d bethgelab/jupyter-scipyserver:$(tag)
daemon-deeplearning:
	GPU=$(gpu) ./agmb-docker run -d bethgelab/jupyter-deeplearning:$(tag)
daemon-torch:
	GPU=$(gpu) ./agmb-docker run -d bethgelab/jupyter-torch:$(tag)

