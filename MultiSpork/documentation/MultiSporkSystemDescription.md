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

Features listed as (OPTIONAL) are ones that I haven't decided I'm definitely going to implement immediately, but that would be nice in the future. 

----------

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

USB is a native peripheral of the microcontroller. The USB port is protected against ESD and electrical insults by series resistors.

USB power is used to charge the battery.

### SD Card ###

A micro-SD card slot provides non-volatile data storage when the Multispork is directed to log incoming data. It also provides storage for outgoing waveforms and (possibly) scripts to run. 

### Idiot Lights ###

The MultiSpork shall have the following idiot lights. Features listed in *italics* have not yet been implemented as of commit 872e8fda3353304001933b7b57375441d28ed381.

* Charge, red LED
* *Power, green LED*
* *State, RGB LED*

### Power ###

#### Switch ####

The power switch controls the enable lines of all of the voltage regulators. In the off position, it puts them all to sleep.  

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

The PCB will be a four-layer design, 0.062" finished thickness. 

### Case ###

The case will be a milled Delrin case with an acrylic lid. It will have space for a battery and associated retention features. The case shall also provide a mechanism to operate the reset button and the power switch. It shall also provide visibility for the charge and power LEDs. 

## Future Hardware Features ##

This is a list of things that I have thought of that would be nice to have but are probably not worth the candle, at least at the time.

* GPS for accurate time and location tagging (see, for example, the SE4150L -- $3/ea in singles). This is significantly more interesting than just an RTC.
* External RAM for larger on-board buffer

----------

# Firmware #

The firmware configures the MAX11300, and exchanges data with the MAX11300, the WiFi, and the SD card. It has the following functions:

* Acquire data from the ADC and GPI at full speed (400 ksps)
* Pipe data to the DAC and GPO at full speed
* Provide access to all major MAX11300 and CC3100 configuration options
* Log data to SD card
* Read arbitrary waveforms from SD card
* Transmit data over WiFi to tablet
* Generate standard analog waveforms (sine, square, triangle, white noise, etc)
* Generate standard digital waveforms (PWM, PCM, etc)
* Capture data from ADC/GPI based on trigger conditions (level and edge triggers)
* Transmit data over DAC/GPO based on trigger conditions
* (OPTIONAL) Apply arbitrary polynomial transfer functions to incoming data
* (OPTIONAL) Apply mathematical functions (add, subtract, multiply, trig) to incoming data
* (OPTIONAL) Pipe filtered data to arbitrary DAC channel
* (OPTIONAL) Read configuration options from SD Card
* (OPTIONAL) Read and write data from accessories on the SPI and I2C busses
* (OPTIONAL) Run arbitrary LUA scripts on incoming/outgoing data

## Configuration ##

The general intention is that the configuration options in the firmware are thin wrappers around the MAX11300 and CC3100 configuration registers. 

## Data Flow ##

The major system blocks are as follows:

* **MAX11300** -- Primary physical interface, both in and out
* **MCU SPI** -- The communications bus with all peripherals save the USB
* **MCU buffers** -- Internal RAM buffers used for input and output 
* **MCU filters** -- Internal filter programs
* **MCU signal generator** -- Algorithmic signal generation
* **SD Card** -- Local SD card for storing data
* **CC3100** -- WiFi connection to host app
* **USB** -- USB connection to host app
* **Host App** -- Host application running on a tablet or other computer

### MAX11300 ###

The MAX11300 block communicates via the MCU SPI block. It takes in commands, configuration, and output data. It puts out input data from its analog and digital inputs. 

### MCU SPI ###

The SPI is the communications bus that connects the MAC11300, the MCU (and all its internal blocks), the SD card, and the CC3100. It may carry any of the data types that these blocks transmit or receive. 

### MCU buffers ###

The MCU buffers incoming and outgoing data from and to the MAX11300 that is either going to or received from other blocks over the SPI. Each active channel has its own buffer, which will be either read or write depending on what function is currently configured on that channel. The WiFi, the USB, and the SD card each have a read and a write buffer.

### MCU filters ###

The MCU can run filters (decimation, low pass, various multi-input math functions etc) against data that is in any buffer. The output is written to another buffer. 

### MCU signal generator ###

The signal generator fills an output buffer with a specified function. Here is a list of functions to be implemented in the first iteration:

* sine wave
* square wave
* triangle wave
* sawtooth wave
* PWM

### SD Card ###

The SD card is a data store that the MCU can either write to or read from via SPI bus.

Output data files will be stored as plain text CSV files in the format <channel>,<time>,<value>,<units>. In the case of raw values, the value of the <units> field shall be 'raw'. Any other value shall be set by the translating filter.

Input data files shall be in .wav format. The name and details of the .wav file are set by the 

### CC3100 ###

The CC3100 provides the WiFi link to the host app. It sends and receives data and commands from the MCU via SPI and communicates with the host app via WiFi. 

### USB ###

The USB performs the same functions as the WiFi when the USB is connected to a host. 

### Host App ###

The host app is the ultimate data sink and source in the system. It provides the following types of data to the device:

* Commands (i.e. state changes, state details)
* Configuration (i.e. trigger settings, channel settings)
* .wav files for data output
* (OPTIONAL) Commands, config, and outgoing data for things attached to the accessory connector.

The host app receives the following types of data from the device:

* Streaming input data from the MAX11300
* Status from various parts of the device

## States ##

### Setup ###

This is the state that the MultiSpork enters upon power-up or reset. In this state, it performs the following tasks before transitioning to either Standby or Logging mode (depending on configuration).

1. Configures CC3100 per one of the following profiles (listed in priority order):
	1. (OPTIONAL) WiFiConf.txt, stored on the SD Card
	2. The wifi configuration stored in the EEPROM of the MCU
	3. The default wifi configuration  
2. Configure the MAX11300 per one of the following configurations (listed in priority order):
	1. (OPTIONAL) IOConf.txt, stored on the SD Card
	2. The I/O configuration stored in the EEPROM of the MCU
	3. The default I/O configuration  
4. Chooses mode to enter based on either EEPROM or (OPTIONAL)SD Card configuration.
5. Gets current data/time from host device.

### Standby ###

This is the default waiting state. The primary activity in this state is executing configuration commands from the host app. The device will depart this state for pre-trigger, running capture, or logging based on input from either the host app or from a command file on the SD card. 

The MCU can generate or output a signal through the MAX11300 in this mode and any other except Setup. 

### Pre-Trigger ###

During the pre-trigger state, the MCU commands the MAX11300 to sample the target channel(s) and saves the buffer such that when the trigger condition occurs, the app can display data from both before and after the trigger condition. 

Trigger conditions can come from any of the following sources:

* Analog input
* Digital input
* Analog output
* Digital output
* Internal timebase

Any of the following conditions can be used to trigger a capture

* Level trigger
* Edge trigger
* Periodic trigger
* Free run

Once the trigger condition is satisfied, the firmware transitions to the next state (either Triggered Capture, Running Capture, or Logging) as dictated by the received commands. 

### Triggered Capture ###

During a triggered capture, the device captures and streams data until it reaches the end of the specified capture window. It then either returns to the pre-trigger state or to standby, depending on whether the triggering is set to be continuous or one-shot.

### Running Capture ###

During a running capture, the device captures and streams data to the host app continuously, either via USB or WiFi. Starting and stopping 

### Logging ###

Logging works like a running capture except that the target is the SD card rather than USB or WiFi. Depending on settings, the MCU filters may decimate or otherwise process the incoming data before writing it out. 

It shall be possible to configure this state such that the logging proceeds for a limited time period and then transitions back to pre-triggered or standby. 

----------

# Host App

The host app will be designed to present the acquired data in a format that can be readily viewed and manipulated by the user. 

The host app shall be written in Kivy or similar cross-platform framework that allows them to run on not only Android tablets but also on Windows, Linux, and Mac. 

The host app interface will follow the wireframes at https://logoselectromechanical.mybalsamiq.com/projects/multispork/

----------

# Communications

The maximum data rate from the MAX11300 is 4.8 Mbps. This provides plenty of SPI bus headroom to stream to the host app and record simultaneously, since its maximum speed is 20 Mbps, as long as there's a minimal amount of framing data. This means that the outgoing data needs to be packed up such that a single set of framing data covers a substantial period of communications. 

