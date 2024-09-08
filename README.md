# Richarduino V7.0
## VHDL files
Most of the VHDL files in this project were written by my instructor, Dr. William Richard, from CSE 462M. I implemented a SPI VHDL module that outputs data and clk to the U3 component, MAX9939, to change the gain of the input signals. In addition, I implemented the XADC VHDL module that converts the input analog signal to data and the VGA module that simple outputs the input signal to a monitor in wave form. I also modified the UART VHDL module so that it transmits data(921600 bits/second) between the CMOD A7 and the host application, which is a GUI written in C.

## ExpressSCH picture

![RicharduinoSchematics](https://github.com/qinzhounick/Richarduino-V7.0/assets/112423678/6c5600ee-2b30-4347-9705-968dcd34ccc9)

## ExpressPCB picture

![RicharduinoBoardLayout](https://github.com/qinzhounick/Richarduino-V7.0/assets/112423678/9c589207-7b33-43b0-87e6-31b1c7b28d1e)
