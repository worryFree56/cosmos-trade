AppVersion=$(shell echo $(shell git describe --tags) | sed 's/^v//')
COMMIT := $(shell git log -1 --format='%H')
LEDGER_ENABLED ?= true
BUILDDIR ?= $(CURDIR)

export GO111MODULE = on


build_tags = netgo
ifeq ($(LEDGER_ENABLED),true)
  ifeq ($(OS),Windows_NT)
    GCCEXE = $(shell where gcc.exe 2> NUL)
    ifeq ($(GCCEXE),)
      $(error gcc.exe not installed for ledger support, please install or set LEDGER_ENABLED=false)
    else
      build_tags += ledger
    endif
  else
    UNAME_S = $(shell uname -s)
    ifeq ($(UNAME_S),OpenBSD)
      $(warning OpenBSD detected, disabling ledger support (https://github.com/cosmos/cosmos-sdk/issues/1988))
    else
      GCC = $(shell command -v gcc 2> /dev/null)
      ifeq ($(GCC),)
        $(error gcc not installed for ledger support, please install or set LEDGER_ENABLED=false)
      else
        build_tags += ledger
      endif
    endif
  endif
endif

ifeq (cleveldb,$(findstring cleveldb,$(COSMOS_BUILD_OPTIONS)))
  build_tags += gcc
endif

whitespace :=
whitespace += $(whitespace)
comma := ,
build_tags_comma_sep := $(subst $(whitespace),$(comma),$(build_tags))




# process linker flags
ldflags = -X github.com/cosmos/cosmos-sdk/version.Version=$(AppVersion) \
 		  	  -X github.com/cosmos/cosmos-sdk/version.Name=trade \
		  	  -X github.com/cosmos/cosmos-sdk/version.AppName=traded \
		  	  -X github.com/cosmos/cosmos-sdk/version.Commit=$(COMMIT) \
		 	    -X "github.com/cosmos/cosmos-sdk/version.BuildTags=$(build_tags_comma_sep)"
ldflags += $(LDFLAGS)
ldflags := $(strip $(ldflags))

build_tags += $(BUILD_TAGS)
build_tags := $(strip $(build_tags))

BUILD_FLAGS := -tags "$(build_tags)" -ldflags '$(ldflags)'

all: install build build-linux

###############################################################################
###                                Documentation                            ###
###############################################################################
BUILD_TARGETS := build install

$(BUILD_TARGETS): go.sum $(BUILDDIR)/
	go $@ -mod=readonly $(BUILD_FLAGS) ./cmd/plugchaind

build-linux:
	GOOS=linux GOARCH=amd64 LEDGER_ENABLED=false $(MAKE) build

build-window:
	GOOS=windows GOARCH=amd64 LEDGER_ENABLED=false $(MAKE) build

###############################################################################
###                          Tools & Dependencies                           ###
###############################################################################
go.sum: go.mod
	echo "Ensure dependencies have not been modified ..."
	go mod verify
	go mod tidy

.PHONY: all build-linux build-window install

###############################################################################
###                               Localnet                                  ###
###############################################################################

# Run a single testnet locally
localnet: 
	@echo "start make install and ./scripts/setup.sh"
	@make install 
	./scripts/setup.sh

.PHONY: localnet

buf: 
	@echo "buf install ......"
	@./scripts/protocgen.sh

swagger: 
	@echo "swagger install ......"
	@./scripts/protoc-swagger-gen.sh

.PHONY: buf swagger


###############################################################################
###                                   Docs                                  ###
###############################################################################
npm-vue: 
	@echo "install vuepress rely ..."
	@cd docs/ && sudo npm install vue && sudo npm install -D vuepress

vuepress: 
	@echo "vuepress build ..."
	@cd docs/ && ./deploy.sh 
	

.PHONY: vuepress