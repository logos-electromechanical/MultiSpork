MultiSpork -- A Wireless Analog/Digital Multitool
=================================================================

# Concept #

The MultiSpork is an analog and digital multitool. It has the following properties:

* It has twenty channels can function as a 12-bit ADC, a 12-bit 25 mA DAC, or a GPIO line. 
* Interfaces wirelessly with a tablet or other display device for user input and data presentation. 
* Robust
* Able to store data locally on an SD card
* Able to operate without continuous network connection
* Initial set-up is easy/straightforward
* Both firmware and app incorporate plug-in frameworks to allow easy 3rd party upgrades.
* Replicates behavior of a mixed-signal oscilloscope
* Replicates behavior of a logic analyzer
* Replicates behavior of a signal generator

# Hardware #

## General Hardware Requirements ##
The hardware must conform to the following requirements:

* It must be electrically robust against common insults, especially over-voltage, over-current conditions, and the sort of ESD likely to be encountered in field conditions.
* It must be robust against plugging connectors in backwards. Therefore, all connectors must be either keyed, tolerant of connector reversal, or both. 
* The hardware must be amenable to expansion
* It must be mechanically robust, particularly the connectors. 

## Subsystems ##

### Analog Front End/Digitizer ###

The ADC/DAC/GPIO services are provided by the MAX11300. This chip provides twenty lines, each of which may be individually programmed to act as an ADC, a DAC, or a GPIO. All ADC and DAC channels are 12-bit, and share a total of 400 ksps. 

Voltage ranges are as follows:

|**Function** 	| **Voltage Range** |
|---------------|-------------------|
|ADC			| 	0-10V			|
|				|	-5V to 5V		|
|				|	-10V-0			|
|				|	0-2.5V			|
|---------------|-------------------|
|DAC			| 	0-10V			|
|				|	-5V to 5V		|
|				|	-10V-0			|
|---------------|-------------------|
|GPI			|	0-5V input		|
|				|	0-2.5V threshold|
|				|	(programmable)	|
|---------------|-------------------|
|GPO			|	0-10V (programmable)|
|---------------|-------------------|

#### Voltage Reference ####

Only the internal voltage reference(s) are available.

#### Temperature ####

Both external temperature sensors lines are hooked up to MMBT3904 transistors. This circuit is cribbed directly from the MAX11300 evaluation board. 

#### Host Interface ####

The SPI lines are hooked directly to the MCU, as are the CNVT and INT lines.

#### I/O Protection Circuit ####

Each of the channels has the following circuit:

The series diodes restrict the voltage at MAX11300 input pin to between -10V and +10V. The PTC fuse limits the current to 25 mA in order to prevent damage. 

#### I/O Connector ####

The analog I/O connector is an FCI 76385-316LF soldered to the edge of the board. This is a 2x16 0.1" pitch pin header. This reduces the height of the assembled board and increases mechanical strength. While this is a keyed connector, it can accept non-keyed IDC plugs. Therefore, the pinout is symmetrical, so that reversing the connector will not connect any power or ground rail to any I/O line or to any other power or ground rail.

Pinout is as follows:

| **Pin** 	| **Function** 		|
|-----------|-------------------|
| 1			| Analog Ground		|
| 2			| +3V3				|
| 3			| Digital Ground	|
| 4			| +5V				|
| 5			| -10V				|
| 6			| +10V				|
| 7			| PORT 00			|
| 8			| PORT 01			|
| 9			| PORT 02			|
| 10		| PORT 03			|
| 11		| PORT 04			|
| 12		| PORT 05			|
| 13		| PORT 06			|
| 14		| PORT 07			|
| 15		| PORT 08			|
| 16		| PORT 09			|
| 17		| PORT 10			|
| 18		| PORT 11			|
| 19		| PORT 12			|
| 20		| PORT 13			|
| 21		| PORT 14			|
| 22		| PORT 15			|
| 23		| PORT 16			|
| 24		| PORT 17			|
| 25		| PORT 18			|
| 26		| PORT 19			|
| 27		| +10V				|
| 28		| -10V				|
| 29		| +5V				|
| 30		| Digital Ground	|
| 31		| +3V3				|
| 32		| Analog Ground		|

### MCU ###

The microcontroller is an Atmel SAM3S4A. This chip comes in a QFN 48 package and sports 256K of flash and 48K of SRAM. Clock speed is 64 MHz and maximum SPI speed is 45 MHz. 

Programming is accomplished either via USB or the JTAG interface. 

A 20 MHz crystal regulates the on-chip crystal oscillator

Microcontroller circuitry follows the datasheet to the extent required & practical.

The SPI bus provides the only means of communication between the major subsystems.

#### Accessory connector ####

The accessory connector exposes the serial communication interfaces of the MCU in order to provide a place for adding additional hardware. It is a 2x5 0.1" pitch pin header. It is not populated by default. 

Pinout is as follows:

| **Pin** 	| **Function** 		|
|-----------|-------------------|
| 1			| MOSI (SPI Bus)	|
| 2			| +3V3				|
| 3			| SCLK (SPI Bus)	|
| 4			| RXD0 (UART0)		|
| 5			| MISO (SPI Bus)	|
| 6			| TXD0 (UART0)		|
| 7			| ACC_CS (SPI Bus)	|
| 8			| SCL (I2C Bus)		|
| 9			| SDA (I2C Bus)		|
| 10		| Digital Ground	|

### WiFi ###

Wireless communication is provided by a Texas Instruments CC3100. This 2.4 GHz WiFi SoC provides all network services required for the MultiSpork to communicate with its host tablet. 

The CC3100 is configured to act as an access point. This eliminates the need for the user to execute any wired configuration step prior to using the MultiSpork. Access point configuration options will naturally be available from the tablet app. 

CC3100 wiring follows the dictates of the datasheet. 

### USB ###

USB is a native peripheral of the microcontroller. The USB port is protected against ESD and electrical insults by series resistors, as 

USB power is used to charge the battery.

### SD Card ###

A micro-SD card slot provides non-volatile data storage when the Multispork is directed to log incoming data. 

### Power ###

#### Battery ####

Main power for the device is provided by a single LiPo cell (2.7-4.2V) with a 2mm JST connector. This battery is intended to be permanently installed, but can be removed and upgraded if required for a specific application.

The battery is charged by an MCP73831 linear charge controller set to 500 mA of charge current. 

#### 3.3V Rail ####

The 3.3V rail powers the MCU, the WiFi chip, and the digital interface of the MAX11300. It therefore has the highest power demand of any of the power rails.

This rail is driven by an LT3580 regulator configured to run in SEPIC mode. The components are sized to provide a current output of 800 mA.  

#### 5V Rail ####

The 5V rail powers the core of the MAX11300. Like the 3.3V rail, it is driven by an LT3580 regulator running in SEPIC mode. The current output is 400 mA. 

#### +10V Rail ####

The +10V provides the high voltage positive rail for the MAX11300. It is driven an LT3580 configured as a boost regulator. Current output is 350 mA. 

#### -10V Rail ####

The -10V provides the high voltage negative rail for the MAX11300. It is driven by an LT3580 configured as an inverting regulator. Current output is 350 mA. 

#### Analog Ground ####

The analog ground plane is connected to the digital ground plane through a small resistor. 

## Mechanical ##

### PCB ###

The production version of the MultiSpork will fit within a Dangerous Prototype DP8049 Sick of Beige footprint. 

The PCB will be a 

### Case ###

# Firmware

# Tablet