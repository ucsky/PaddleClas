SHELL := /bin/bash -i # Bourne-Again SHell command-line interpreter on Linux.
SCRIPT := $(PWD)/script
PYTHON := python3.10
### 

# Hack for displaying help message in Makefile
help: 
	@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

###

venv-install-gpu:



.local.env:
	-(touch .local.env)

venv-build-cpu: ## Create Python environement with venv for CPU.
venv-build-cpu: venv/cpu/bin/activate
venv/cpu/bin/activate: .local.env
	-( \
	. .local.env \
	&& test -d venv/cpu \
	|| $(PYTHON) -m venv venv/cpu \
	)
	-( \
	. .local.env \
	&& . venv/cpu/bin/activate \
	&& pip install -U pip \
	&& pip install paddlepaddle --upgrade -i https://mirror.baidu.com/pypi/simple \
	)

venv-test-cpu: ## Test venv CPU install.
venv-test-cpu:  venv/cpu/bin/activate .local.env
	-( \
	. .local.env \
	&& . venv/cpu/bin/activate \
	&& python -c "import paddle; paddle.utils.run_check()" \
	)


venv-clean-cpu: ## Clean venv CPU env.
venv-clean-cpu:
	rm -rf venv/cpu


venv-build-gpu: ## Create Python environement with venv for GPU.
venv-build-gpu: venv/gpu/bin/activate
venv/gpu/bin/activate: .local.env
	-( \
	. .local.env \
	&& test -d venv/gpu \
	|| $(PYTHON) -m venv venv/gpu \
	)
	-( \
	. .local.env \
	&& . venv/gpu/bin/activate \
	&& pip install -U pip \
	&& pip install paddlepaddle-gpu --upgrade -i https://mirror.baidu.com/pypi/simple \
	)


venv-test-gpu: ## Test venv GPU install.
venv-test-gpu:  venv/gpu/bin/activate .local.env
	-( \
	. .local.env \
	&& . venv/gpu/bin/activate \
	&& python -c "import paddle; paddle.utils.run_check()" \
	)

venv-clean-gpu: ## Clean venv GPU env.
venv-clean-gpu:
	rm -rf venv/gpu


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

