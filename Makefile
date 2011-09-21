ARCH = i386
TOP_D = $(shell pwd)
BR_D = $(TOP_D)/buildroot
OUT_D = $(TOP_D)/output/$(ARCH)
BR_OUT_D = $(OUT_D)/buildroot
CONF_D = $(TOP_D)/conf
DL_D = $(TOP_D)/download
SKEL_D = $(OUT_D)/skeleton

DISK_IMG = $(OUT_D)/disk.img
PART_IMG = $(OUT_D)/part.img
TAR_IMG = $(OUT_D)/rootfs.tar
BR_TAR_IMG = $(BR_OUT_D)/images/rootfs.tar

BR_MAKE = cd $(BR_D) && make O=$(BR_OUT_D) BR2_DL_DIR=$(DL_D) \
   BUSYBOX_CONFIG_FILE=$(BR_OUT_D)/busybox.config \
   BR2_ROOTFS_SKELETON_CUSTOM_PATH=$(SKEL_D)

BR_DEPS = $(BR_D) $(BR_OUT_D)/busybox.config $(BR_OUT_D)/.config $(SKEL_D)/.dir

all: $(TAR_IMG)

debug:
	@echo "BR_DEPS: $(BR_DEPS)"
	@echo "BR_MAKE: $(BR_MAKE)"
	@echo "BR_OUT_D: $(BR_OUT_D)"

source: br_source minicloud_source

br_source: $(BR_DEPS) $(OUT_D)/.source.$(ARCH)
minicloud_source: $(DL_D)/.dir
	@echo hi world
	# here we would download the Ubuntu kernel

$(BR_D):
	@[ -d "$(BR_D)" ] || { echo "You Must download BUILDROOT, extract it, and symlink to $(BR_D)"; exit 1; }

$(OUT_D)/.source.$(ARCH): 
	$(BR_MAKE) source

$(BR_OUT_D)/busybox.config: $(CONF_D)/busybox.config $(BR_OUT_D)/.dir
	cp $(CONF_D)/busybox.config $@

$(BR_OUT_D)/.config: $(CONF_D)/buildroot-$(ARCH).config $(BR_OUT_D)/.dir
	cp $(CONF_D)/buildroot-$(ARCH).config $@

$(TAR_IMG): $(BR_TAR_IMG)
	cp $(BR_TAR_IMG) $(TAR_IMG)

$(BR_TAR_IMG): $(BR_DEPS)
	$(BR_MAKE)

$(SKEL_D)/.dir:
	# copy BR_D/fs/skeleton, then sync src/ over the
	# top of that.
	# depends on $(BR_D)/fs/skeleton (somehow)

%/.dir:
	mkdir -p $* && touch $@