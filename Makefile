#!/usr/bin/make -f

SHELL := /bin/bash


images:
	docker build \
		-t phlax/nfs-server \
		github.com/phlax/docker-nfs-server#build
	docker build \
	         -t phlax/nfs-client \
		docker

proxy-example:
	docker build \
		-t phlax/example-nfs-proxy \
		example/proxy

pysh:
	pip install -U pip setuptools termcolor
	pip install -e 'git+https://github.com/phlax/pysh#egg=pysh.test&subdirectory=pysh.test'

hub-images:
	docker push phlax/nfs-server
	docker push phlax/nfs-client
