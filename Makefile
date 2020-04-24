#!/usr/bin/make -f

SHELL := /bin/bash


image:
	docker build \
		-t phlax/nfs-server \
		github.com/phlax/docker-nfs-server#grace-period
	docker build \
	         -t phlax/nfs-client \
		docker

pysh:
	pip install -U pip setuptools termcolor
	pip install -e 'git+https://github.com/phlax/pysh#egg=pysh.test&subdirectory=pysh.test'
