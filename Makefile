# riberion
# see license file for copyright and license details

LOAD_PATH    := ./
SYSTEMS_PATH := ./systems

CORES := $(shell nproc)

all: options

options:
	@printf '\n'
	@printf '-----------------------------------------------------------\n'
	@printf ' * general\n'
	@printf '-----------------------------------------------------------\n'
	@printf 'update -- updates Guix packages & system\n'
	@printf 'iso    -- creates .iso image to flashed (non-free Kernel)\n'
	@printf '\n'
	@printf '\n'
	@printf '-----------------------------------------------------------\n'
	@printf '* machines (read docs for info)\n'
	@printf '-----------------------------------------------------------\n'
	@printf 'ASUS GL502VMK ::\n'
	@printf 'asus-build            -- builds the ASUS profile\n'
	@printf 'asus-reconf           -- builds & switches to the ASUS profile\n'
	@printf 'asus-reconf-no-update -- builds & switches to the ASUS profile (does not pull updates)\n'
	@printf 'asus-init             -- installs the ASUS profile\n'
	@printf '\n'
	@printf '\n'
	@printf '-----------------------------------------------------------\n'
	@printf ' * GNU Emacs is needed for tangling files\n'
	@printf '-----------------------------------------------------------\n'
	@printf 'tangle -- tangles *.org files to create all needed files\n'
	@printf '\n'

tangle: systems.org
	git clean -fdx
	@emacs --batch --eval "(require 'org)" \
        	--eval '(org-babel-tangle-file "$<")' && \
        	printf '\n...files were tangled\n'

update: tangle
	guix pull --cores=${CORES} --channels='./guix/channels.scm'
	hash guix
	guix upgrade

asus-build: update
	guix time-machine --channels='./guix/channels.scm' -- \
		system --cores=${CORES} --load-path=${LOAD_PATH} build ${SYSTEMS_PATH}/asus.scm

asus-reconf: update
	sudo -E guix time-machine --channels='./guix/channels.scm' -- \
		system --cores=${CORES} --load-path=${LOAD_PATH} reconfigure ${SYSTEMS_PATH}/asus.scm

asus-reconf-no-update: tangle
	sudo -E guix time-machine --channels='./guix/channels.scm' -- \
		system --cores=${CORES} --load-path=${LOAD_PATH} reconfigure ${SYSTEMS_PATH}/asus.scm

asus-init: update
	guix time-machine --channels='./guix/channels.scm' -- \
		system --cores=${CORES} --load-path=${LOAD_PATH} init ${SYSTEMS_PATH}/asus.scm /mnt

iso: update
	guix time-machine --channels='./guix/channels.scm' -- \
		system --cores=${CORES} image --image-type=iso9660 --image-size=3G ./guix/install.scm
	@printf 'dd bs=4M status=progress oflag=sync if=XYZ123.iso of=/dev/XYZ\n'

.PHONY: all options tangle update asus-reconf asus-reconf-no-update asus-build asus-init iso
