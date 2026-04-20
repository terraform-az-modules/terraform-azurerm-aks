GENIE_PATH ?= $(shell pwd)/../../../genie

ifeq ($(wildcard $(GENIE_PATH)),)
GENIE_PATH := $(shell pwd)/genie
endif

include $(GENIE_PATH)/Makefile
