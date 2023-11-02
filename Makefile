SHELL := /bin/bash -i # Bourne-Again SHell command-line interpreter on Linux.
PYTHON_VERSION := 3.7
PYTHON := python$(PYTHON_VERSION)
### 

# Hack for displaying help message in Makefile
help: 
	@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

###

include .local.env

.local.env:
	-(touch .local.env)

conda-build-gpu: ## Create Python environement with conda for GPU.
conda-build-gpu:
	-( \
	test -f ~/activate/miniconda3 && . ~/activate/miniconda3 || true \
	&& conda env list | grep '^PaddleClasGpu\s' > /dev/null  \
	|| conda create --name PaddleClasGpu python=$(PYTHON_VERSION) -y \
	&& conda activate PaddleClasGpu \
	&& pip install -U pip \
	&& pip install paddlepaddle-gpu --upgrade -i https://mirror.baidu.com/pypi/simple \
	)

conda-clean-gpu: ## Clean Python environement with conda for GPU.
conda-clean-gpu:
	-(\
	test -f ~/activate/miniconda3 && . ~/activate/miniconda3 || true \
	&& conda env remove --name PaddleClasGpu \
	)

conda-test-gpu: ## Clean Python environement with conda for GPU.
conda-test-gpu:
	-(\
	test -f ~/activate/miniconda3 && . ~/activate/miniconda3 || true \
	&& conda activate PaddleClasGpu \
	&& python -c "import paddle; paddle.utils.run_check()" \
	)


conda-build-cpu: ## Create Python environement with conda for CPU.
conda-build-cpu:
	-( \
	test -f ~/activate/miniconda3 && . ~/activate/miniconda3 || true \
	&& conda env list | grep '^PaddleClasCpu\s' > /dev/null  \
	|| conda create --name PaddleClasCpu python=$(PYTHON_VERSION) -y \
	&& conda activate PaddleClasCpu \
	&& pip install -U pip \
	&& pip install paddlepaddle --upgrade -i https://mirror.baidu.com/pypi/simple \
	)

conda-clean-cpu: ## Clean Python environement with conda for CPU.
conda-clean-cpu:
	-(\
	test -f ~/activate/miniconda3 && . ~/activate/miniconda3 || true \
	&& conda env remove --name PaddleClasCpu \
	)

conda-test-cpu: ## Clean Python environement with conda for CPU.
conda-test-cpu:
	-(\
	test -f ~/activate/miniconda3 && . ~/activate/miniconda3 || true \
	&& conda activate PaddleClasCpu \
	&& python -c "import paddle; paddle.utils.run_check()" \
	)


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
	-it paddlepaddle/paddle:2.5.2-gpu-cuda12.0-cudnn8.9-trt8.6 /bin/bash 

