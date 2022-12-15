# @Author: rx-ted
# @Date: 2022-12-15 18:00:07
# @LastEditors: rx-ted
# @LastEditTime: 2022-12-15 21:05:31

# 根据前人经验改进合适自己的代码


######################################
# target
######################################
TARGET = output

######################################
# building variables
######################################
# debug build
ifeq ($(release), y)
DEBUG = 0
else
DEBUG = 1
endif
# optimization
OPT = -Os

#######################################
# Build path
#######################################
BUILD_DIR = build

######################################
# chip platform info
######################################
TARGET_PLATFORM := n32g4fr
DEFS += -DN32G4fr
DEFS += -DUSE_STDPERIPH_DRIVER

######################################
# Algo libs
######################################
USELIB = 1

######################################
#TOOLS CHAIN
######################################
CROSS_COMPILE = arm-none-eabi-

######################################
# C sources
######################################
C_DIRS += src
C_DIRS += firmware/CMSIS/device
C_DIRS += firmware/$(TARGET_PLATFORM)_std_periph_driver/src
C_DIRS += firmware/$(TARGET_PLATFORM)_usbfs_driver/src
SRC_OBJS_DIRS += $(foreach DIR, $(C_DIRS), $(wildcard $(DIR)/*.c))
C_SOURCES = $(SRC_OBJS_DIRS)

######################################
# ASM sources
######################################
ASM_SOURCES = firmware/CMSIS/device/startup/startup_$(TARGET_PLATFORM)_gcc.s

######################################
# C includes
######################################
C_INCS += include
C_INCS += firmware/CMSIS/core
C_INCS += firmware/CMSIS/device
C_INCS += firmware/$(TARGET_PLATFORM)_std_periph_driver/inc
C_INCS += firmware/$(TARGET_PLATFORM)_usbfs_driver/inc
INCS_OBJS_DIR = $(foreach DIR2, $(C_INCS), $(wildcard $(DIR2)/*.h))
INCS_OBJS_PATH = $(sort $(dir $(INCS_OBJS_DIR)))
C_INCLUDES = $(addprefix -I,$(INCS_OBJS_PATH))

######################################
# Lib files
######################################
ifeq ($(USELIB), 1)
SRC_LIB_DIR += firmware/$(TARGET_PLATFORM)_algo_lib/src
INC_LIB_DIR += firmware/$(TARGET_PLATFORM)_algo_lib/inc
LIB_SOURCES = $(foreach DIR3, $(SRC_LIB_DIR), $(wildcard $(DIR3)/*.lib))
LIB_SOURCES_L = $(addprefix -L,$(LIB_SOURCES))
C_LIBS = $(LIB_SOURCES_L)
LIB_INCS = $(foreach DIR4, $(INC_LIB_DIR), $(wildcard $(DIR4)/*.h))
LIB_INCS_PATH = $(sort $(dir $(LIB_INCS)))
LIB_INCS_PATH_I = $(addprefix -I,$(LIB_INCS_PATH))
C_INCLUDES += $(LIB_INCS_PATH_I)
endif

######################################
# Compile & Link flags
######################################
# cpu
CPU = -mcpu=cortex-m4
# fpu
FPU = -mfpu=fpv4-sp-d16
# float-abi
FLOAT-ABI = -mfloat-abi=soft  # hard soft softfp
# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)
#CFLAGS
CFLAGS += $(MCU) -Wall
CFLAGS += $(OPT)
CFLAGS += -ffunction-sections -fdata-sections
#DEBUG
ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif
# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"
#LFLAGS
LFLAGS += $(MCU)
LFLAGS += -Wl,--gc-sections 
LFLAGS += --specs=nosys.specs
LFLAGS += -Xlinker -Map=$(BUILD_DIR)/$(TARGET).map
# link script
LDSCRIPT = firmware/CMSIS/device/$(TARGET_PLATFORM)_flash.ld

######################################
# Objects
######################################
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CROSS_COMPILE)gcc $(CFLAGS) $(DEFS) $(C_INCLUDES) $(C_LIBS) -c -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@
    
$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $< -o $@
    
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CROSS_COMPILE)gcc $(OBJECTS) $(LFLAGS) -T$(LDSCRIPT) -o $@
	$(CROSS_COMPILE)size $@
	
$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	$(CROSS_COMPILE)objcopy -O binary -S $< $@

$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
	$(CROSS_COMPILE)objcopy -O ihex -S $< $@
    
$(BUILD_DIR):
	@-mkdir $@

#######################################
# clean up
#######################################
clean:
	@-rm -rf $(BUILD_DIR)

#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)
