SHELL := /bin/bash -i # Bourne-Again SHell command-line interpreter on Linux.
SCRIPT := $(PWD)/script
PYTHON := python3.10
### 

# Hack for displaying help message in Makefile
help: 
	@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

###

conda-install: ## Install conda env for CPU
conda-install:
	-(. ~/activate/miniconda3 \
	&& conda env list | egrep "^PaddleClasCpu\s"  && true || conda create --name PaddleClasCpu python=3.10 -y \
	&& conda activate PaddleClasCpu \
	&& which python \
	&& pip install -U pip \
	&& pip install paddlepaddle --upgrade -i https://mirror.baidu.com/pypi/simple \
	)	


docker-run-cpu-it: ## Run docker images for CPU users in interactive mode.  
docker-run-cpu-it:
	docker run \
	--name ppcls-cpu-dev \
	--rm \
	-v $PWD:/paddle \
	--shm-size=8G \
	--network=host \
	-it paddlepaddle/paddle:2.1.0 /bin/bash


docker-run-gpu-it: ## Run docker images for GPU users in interactive mode.  
docker-run-gpu-it:
	docker run \
	--name ppcls-gpu-dev \
	-v $PWD:/paddle \
	--rm \
	--shm-size=8G \
	--network=host \
	--gpus all \
	-it paddlepaddle/paddle:2.1.0-gpu-cuda10.2-cudnn7 /bin/bash 

