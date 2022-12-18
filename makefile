CROSS_COMPILE=arm-none-eabi-
#CROSS_COMPILE =/opt/arm-2011.03/bin/arm-none-eabi-
CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
AR=$(CROSS_COMPILE)ar
AS=$(CROSS_COMPILE)as
OC=$(CROSS_COMPILE)objcopy
OD=$(CROSS_COMPILE)objdump
SZ=$(CROSS_COMPILE)size

MCU = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard 
DEFS += -DN32G4FR
DEFS += -DUSE_STDPERIPH_DRIVER

CFLAGS= -c -fno-common \
	-ffunction-sections \
	-fdata-sections \
	-Os \
	-g3 \
	-Wall \
	$(MCU)

LDSCRIPT=ld/n32g4fr_flash.ld
LDFLAGS	= --gc-sections,-T$(LDSCRIPT),-nostdlib,-lnosys
OCFLAGS	= -Obinary
ODFLAGS	= -S
OUTPUT_DIR = output
TARGET  = $(OUTPUT_DIR)/main

INCLUDE = -I./src/fw_lib/include \
	  -I./src/include \
	  -I ./include


SRCS = 	 \
	./src/n32g4fr_it.c \
	./src/fw_lib/n32g4fr_gpio.c \
	./src/fw_lib/n32g4fr_rcc.c \
	./src/fw_lib/system_n32g4fr.c \
	./src/main.c


OBJS=$(SRCS:.c=.o)

.PHONY : clean all

all: $(TARGET).bin  $(TARGET).list
	$(SZ) $(TARGET).elf

clean:
	-find . -name '*.o'   -exec rm {} \;
	-find . -name '*.elf' -exec rm {} \;
	-find . -name '*.lst' -exec rm {} \;
	-find . -name '*.out' -exec rm {} \;
	-find . -name '*.bin' -exec rm {} \;
	-find . -name '*.map' -exec rm {} \;

$(TARGET).list: $(TARGET).elf
	$(OD) $(ODFLAGS) $< > $(TARGET).lst

$(TARGET).bin: $(TARGET).elf
	$(OC) $(OCFLAGS) $(TARGET).elf $(TARGET).bin

$(TARGET).elf: $(OBJS) ./src/startup.o
	@$(CC) $(MCU) -Wl,$(LDFLAGS),-o$(TARGET).elf,-Map,$(TARGET).map ./src/startup.o $(OBJS)

%.o: %.c
	@echo "  CC $<"
	@$(CC) $(INCLUDE) $(DEFS) $(CFLAGS)  $< -o $*.o

%.o: %.S
	@echo "  CC $<"
	@$(CC) $(INCLUDE) $(DEFS) $(CFLAGS)  $< -o $*.o
