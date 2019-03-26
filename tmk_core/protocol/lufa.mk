LUFA_DIR = protocol/lufa

# Path to the LUFA library
LUFA_PATH ?= $(LUFA_DIR)/LUFA-git


# Create the LUFA source path variables by including the LUFA makefile
ifneq (, $(wildcard $(TMK_DIR)/$(LUFA_PATH)/LUFA/Build/lufa_sources.mk))
    # New build system from 20120730
    LUFA_ROOT_PATH = $(LUFA_PATH)/LUFA
    include $(TMK_DIR)/$(LUFA_PATH)/LUFA/Build/lufa_sources.mk 
else
    include $(TMK_DIR)/$(LUFA_PATH)/LUFA/makefile
endif

LUFA_SRC = $(LUFA_DIR)/lufa.c \
	   $(LUFA_DIR)/descriptor.c \
	   $(LUFA_SRC_USB)

SRC += $(LUFA_SRC)

# Search Path
VPATH += $(TMK_DIR)/$(LUFA_DIR)
VPATH += $(TMK_DIR)/$(LUFA_PATH)

# Option modules
#ifdef $(or MOUSEKEY_ENABLE, PS2_MOUSE_ENABLE)
#endif

#ifdef EXTRAKEY_ENABLE
#endif

# LUFA library compile-time options and predefined tokens
LUFA_OPTS  = -DUSB_DEVICE_ONLY
LUFA_OPTS += -DUSE_FLASH_DESCRIPTORS
LUFA_OPTS += -DUSE_STATIC_OPTIONS="(USB_DEVICE_OPT_FULLSPEED | USB_OPT_REG_ENABLED | USB_OPT_AUTO_PLL)"
#LUFA_OPTS += -DINTERRUPT_CONTROL_ENDPOINT
LUFA_OPTS += -DFIXED_CONTROL_ENDPOINT_SIZE=8 
LUFA_OPTS += -DFIXED_NUM_CONFIGURATIONS=1
# Remote wakeup fix for ATmega32U2        https://github.com/tmk/tmk_keyboard/issues/361
ifeq ($(MCU),atmega32u2)
	LUFA_OPTS += -DNO_LIMITED_CONTROLLER_CONNECT
endif

OPT_DEFS += -DF_USB=$(F_USB)UL
OPT_DEFS += -DARCH=ARCH_$(ARCH)
OPT_DEFS += $(LUFA_OPTS)

# This indicates using LUFA stack
OPT_DEFS += -DPROTOCOL_LUFA

ifeq (yes,$(strip $(LUFA_DEBUG)))
    LUFA_OPTS += -DLUFA_DEBUG
endif

ifeq (yes,$(strip $(LUFA_DEBUG_SUART)))
    SRC += common/avr/suart.S
    LUFA_OPTS += -DLUFA_DEBUG_SUART
    # Keep print/debug lines when disabling HID console. See common.mk.
    DEBUG_PRINT_AVAILABLE = yes
endif

ifeq (yes,$(strip $(LUFA_DEBUG_UART)))
    SRC += common/uart.c
    LUFA_OPTS += -DLUFA_DEBUG_UART
    # Keep print/debug lines when disabling HID console. See common.mk.
    DEBUG_PRINT_AVAILABLE = yes
endif
