# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Makefile to pick from the different available projects that can be used from
# to compile a working kernel image


############################################################################
########################## GLOBAL MAKE ARGUMENTS ###########################
############################################################################

export PROJECT := XT890-Kernel-Gamma

############################################################################
##################### LOCAL SETUP AND FILE STRUCTURES ######################
############################################################################

PROJ_PATH = $(PWD)/projects/$(PROJECT)
KSRC_PATH = $(PWD)/projects/$(PROJECT)/kernel
REPO_HTTP = https://github.com/oxavelar/
KSRC_HTTP = $(REPO_HTTP)/$(PROJECT)

############################################################################
########################### KERNEL BUILD STEPS #############################
############################################################################

.PHONY: kernel
kernel: picker
	$(MAKE) -C $(PROJ_PATH)
	mv -avf $(PROJ_PATH)/out $(PWD)/out

.PHONY: clean
clean:
	$(MAKE) -C $(PROJ_PATH) clean

.PHONY: picker
picker:
	#export PROJECT := XT890-Kernel-Gamma
	git clone $(KSRC_HTTP) $(KSRC_PATH) || continue

