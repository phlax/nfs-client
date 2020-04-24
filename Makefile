#!/usr/bin/make -f

SHELL := /bin/bash


image:
	docker build \
	         -t phlax/nfs-client \
		docker
