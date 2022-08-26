###### You should not need to modify this file. Edit build.yaml instead. ######

debug:

BUILD_DIR:=.build

$(shell ruby scripts/yaml2make.rb build.yaml .build.yaml.mk)
$(eval -include .build.yaml.mk)


define init_components
$(shell ruby scripts/component2make.rb $(1)/component.yaml $(1)/.build.yaml.mk $(1));
$(eval undefine C_SOURCES);
$(eval undefine CXX_SOURCES);
$(eval undefine INCLUDE_DIRS);
$(eval -include $(1)/.build.yaml.mk);
$(eval CFLAG_INCLUDES+=$(foreach i,$(INCLUDE_DIRS),-I$(i)));
$(eval ALL_SOURCE_FILES+=$(C_SOURCES));
$(eval ALL_SOURCE_FILES+=$(CXX_SOURCES));
$(eval ALL_SOURCE_FILES+=$(ASM_SOURCES));
$(eval ALL_INCLUDE_DIRS+=$(INCLUDE_DIRS));
endef

define dep_target
$(BUILD_DIR)/$1/$(basename $2).d
endef

define obj_target
$(BUILD_DIR)/$1/$(basename $2).o
endef

define build_object
$(1): $(2) $(3) | BUILD_DIRS
	@$$(info Compiling: $(2))
	@$(6) $(5) -c $(2) -o $(1)
endef

define build_dep
$(3): $(2) | BUILD_DIRS
	@$$(info Resolving: $(2))
	@$(6) $(5) -MP -MT $(1) -M $(2) -o $(3)
endef

define c_build_targets
$(eval undefine C_SOURCES);
$(eval undefine CXX_SOURCES);
$(eval undefine INCLUDE_DIRS);
$(eval -include $(1)/.build.yaml.mk);
$(foreach c_source,$(C_SOURCES),\
	$(eval c_debug_object:=$(call obj_target,debug,$(c_source)))\
	$(eval c_release_object:=$(call obj_target,release,$(c_source)))\
	$(eval c_debug_dep:=$(call dep_target,debug,$(c_source)))\
	$(eval c_release_dep:=$(call dep_target,release,$(c_source)))\
	$(eval $(call build_object,$(c_debug_object),$(c_source),$(c_debug_dep),$(1)/component.yaml,$(CFLAGS) $(DEBUG_CFLAGS) $(CFLAG_INCLUDES),$(CC)))\
	$(eval $(call build_dep,$(c_debug_object),$(c_source),$(c_debug_dep),$(1)/component.yaml,$(CFLAGS) $(DEBUG_CFLAGS) $(CFLAG_INCLUDES),$(CC)))\
	$(eval $(call build_object,$(c_release_object),$(c_source),$(c_release_dep),$(1)/component.yaml,$(CFLAGS) $(RELEASE_CFLAGS) $(CFLAG_INCLUDES),$(CC)))\
	$(eval $(call build_dep,$(c_release_object),$(c_source),$(c_release_dep),$(1)/component.yaml,$(CFLAGS) $(RELEASE_CFLAGS) $(CFLAG_INCLUDES),$(CC)))\
	$(eval -include $(c_debug_dep))\
	$(eval -include $(c_release_dep))\
);
$(foreach c_source,$(CXX_SOURCES),\
	$(eval c_debug_object:=$(call obj_target,debug,$(c_source)))\
	$(eval c_release_object:=$(call obj_target,release,$(c_source)))\
	$(eval c_debug_dep:=$(call dep_target,debug,$(c_source)))\
	$(eval c_release_dep:=$(call dep_target,release,$(c_source)))\
	$(eval $(call build_object,$(c_debug_object),$(c_source),$(c_debug_dep),$(1)/component.yaml,$(CXXFLAGS) $(DEBUG_CXXFLAGS) $(CFLAG_INCLUDES),$(CXX)))\
	$(eval $(call build_dep,$(c_debug_object),$(c_source),$(c_debug_dep),$(1)/component.yaml,$(CXXFLAGS) $(DEBUG_CXXFLAGS) $(CFLAG_INCLUDES),$(CXX)))\
	$(eval $(call build_object,$(c_release_object),$(c_source),$(c_release_dep),$(1)/component.yaml,$(CXXFLAGS) $(RELEASE_CXXFLAGS) $(CFLAG_INCLUDES),$(CXX)))\
	$(eval $(call build_dep,$(c_release_object),$(c_source),$(c_release_dep),$(1)/component.yaml,$(CXXFLAGS) $(RELEASE_CXXFLAGS) $(CFLAG_INCLUDES),$(CXX)))\
	$(eval -include $(c_debug_dep))\
	$(eval -include $(c_release_dep))\
);
$(foreach c_source,$(ASM_SOURCES),\
	$(eval c_debug_object:=$(call obj_target,debug,$(c_source)))\
	$(eval c_release_object:=$(call obj_target,release,$(c_source)))\
	$(eval c_debug_dep:=$(call dep_target,debug,$(c_source)))\
	$(eval c_release_dep:=$(call dep_target,release,$(c_source)))\
	$(eval $(call build_object,$(c_debug_object),$(c_source),$(c_debug_dep),$(1)/component.yaml,$(ASMFLAGS) $(DEBUG_ASMFLAGS) $(CFLAG_INCLUDES),$(ASMC)))\
	$(eval $(call build_dep,$(c_debug_object),$(c_source),$(c_debug_dep),$(1)/component.yaml,$(ASMFLAGS) $(DEBUG_ASMFLAGS) $(CFLAG_INCLUDES),$(ASMC)))\
	$(eval $(call build_object,$(c_release_object),$(c_source),$(c_release_dep),$(1)/component.yaml,$(ASMFLAGS) $(RELEASE_ASMFLAGS) $(CFLAG_INCLUDES),$(ASMC)))\
	$(eval $(call build_dep,$(c_release_object),$(c_source),$(c_release_dep),$(1)/component.yaml,$(ASMFLAGS) $(RELEASE_ASMFLAGS) $(CFLAG_INCLUDES),$(ASMC)))\
	$(eval -include $(c_debug_dep))\
	$(eval -include $(c_release_dep))\
);
endef

$(foreach c,$(COMPONENTS),$(call init_components,$(c)))

$(shell ruby scripts/update_vscode.rb i $(sort $(ALL_INCLUDE_DIRS)))
$(shell ruby scripts/update_vscode.rb d $(sort $(CFLAGS) $(DEBUG_CFLAGS) $(CFLAG_INCLUDES)))

DEBUG_BUILD_DIRS:=$(sort $(foreach f,$(ALL_SOURCE_FILES),$(BUILD_DIR)/debug/$(dir $(f))))
RELEASE_BUILD_DIRS:=$(sort $(foreach f,$(ALL_SOURCE_FILES),$(BUILD_DIR)/release/$(dir $(f))))

BUILD_DIRS: $(DEBUG_BUILD_DIRS) $(RELEASE_BUILD_DIRS)

$(foreach c,$(COMPONENTS),$(call c_build_targets,$(c)))




DEBUG_O=$(sort $(foreach f,$(ALL_SOURCE_FILES),$(call obj_target,debug,$(f))))
RELEASE_O=$(sort $(foreach f,$(ALL_SOURCE_FILES),$(call obj_target,release,$(f))))

DEBUG_ELF=$(BUILD_DIR)/debug.elf
RELEASE_ELF=$(BUILD_DIR)/release.elf

DEBUG_HEX=$(BUILD_DIR)/debug.hex
RELEASE_HEX=$(BUILD_DIR)/release.hex

DEBUG_SETTINGS_HEX=$(BUILD_DIR)/debug-settings.hex
RELEASE_SETTINGS_HEX=$(BUILD_DIR)/release-settings.hex

RELEASE_DFU=$(BUILD_DIR)/release-$(DFU_APP_VERSION)-dfu.zip

debug: $(DEBUG_ELF) $(DEBUG_HEX) $(DEBUG_SETTINGS_HEX)
release: $(RELEASE_ELF) $(RELEASE_HEX) $(RELEASE_SETTINGS_HEX) $(RELEASE_DFU)

$(DEBUG_ELF): $(DEBUG_O) $(LDSCRIPT)
	$(info Linking: $@)
	@$(LD) $(LDFLAGS) -T$(LDSCRIPT) $(DEBUG_O) $(DEBUG_LDFLAGS) $(LD_LIBS) -o $@

$(DEBUG_HEX): $(DEBUG_ELF)
	$(info Generating: $@)
	@$(OBJCOPY) -O ihex $< $@

$(DEBUG_SETTINGS_HEX): $(DEBUG_HEX)
	$(info Generating: $@)
	@$(NRFUTIL) settings generate --family NRF52840 --application $< --application-version 1 --bootloader-version 1 --bl-settings-version 1 $@

$(RELEASE_ELF): $(RELEASE_O) $(LDSCRIPT)
	$(info Linking: $@)
	@$(LD) $(LDFLAGS) -T$(LDSCRIPT) $(RELEASE_O) $(RELEASE_LDFLAGS) -o $@

$(RELEASE_HEX): $(RELEASE_ELF)
	$(info Generating: $@)
	@$(OBJCOPY) -O ihex $< $@

$(RELEASE_SETTINGS_HEX): $(RELEASE_HEX)
	$(info Generating: $@)
	@$(NRFUTIL) settings generate --family NRF52840 --application $< --application-version $(DFU_APP_VERSION) --bootloader-version 1 --bl-settings-version 1 $@

$(RELEASE_DFU): $(RELEASE_HEX) $(RELEASE_SETTINGS_HEX)
	@$(NRFUTIL) pkg generate --hw-version 52 --application-version $(DFU_APP_VERSION) --application $(RELEASE_HEX) --sd-req $(DFU_SD_REQ) --key-file $(DFU_KEY_FILE) $(RELEASE_DFU)


ifeq ($(OS),Windows_NT)
$(DEBUG_BUILD_DIRS):
	$(info Creating build directory: $@)
	@-md "$@"
$(RELEASE_BUILD_DIRS):
	$(info Creating build directory: $@)
	@-md "$@"
clean:
	$(info Cleaning...)
	@-powershell "remove-item -Recurse -Force $(BUILD_DIR)"
else
$(DEBUG_BUILD_DIRS):
	@-mkdir -p $@
$(RELEASE_BUILD_DIRS):
	@-mkdir -p $@
clean:
	$(info Cleaning...)
	@-rm -rf $(BUILD_DIR)
endif


flash_debug_hex: $(DEBUG_HEX) $(DEBUG_SETTINGS_HEX)
# @$(NRFJPROG) -f nrf52 --recover
	@echo "===== $(DEBUG_HEX) ====="
	@$(NRFJPROG) -f nrf52 --verify --fast --program $(DEBUG_HEX) --sectorerase
# @echo "===== $(SOFTDEVICE_HEX) ====="
# @$(NRFJPROG) -f nrf52 --verify --fast --program $(SOFTDEVICE_HEX) --sectorerase
	@echo "===== $(DEBUG_SETTINGS_HEX) ====="
	@$(NRFJPROG) -f nrf52 --verify --fast --program $(DEBUG_SETTINGS_HEX) --sectorerase
# @echo "===== $(BOOTLOADER_HEX) ====="
# @$(NRFJPROG) -f nrf52 --verify --fast --program $(BOOTLOADER_HEX) --sectorerase
	@$(NRFJPROG) -f nrf52 --reset
