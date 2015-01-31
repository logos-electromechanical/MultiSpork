# Communications #

## Hardware Components ##

### Host ###

The host is the user interface device. Typically, this will be an app running on an Android tablet, but it may be any computer running the appropriate software. 

Typically, all transactions with the exception of raising interrupts are initiated by the host. 

### Device ###

The device is the operational head of the system. The Multispork is the only device at this time. 

# Transactions #

Each transaction starts with the initiating party (always the host except for raising interrupts) send a request. The other party then sends one or more messages in response. 

Communications is serialized with the [Cap'n Proto](https://capnproto.org/) package. All message descriptions use the terminology of that package. 

## Parameters ##

Parameters are the configuration values used to tell the device how to operate. The value and identity of each parameter are defined with the type `ParamStruct`.

### Messages ###

#### `ParamStruct` ####

This structure contains all the information required for a particular parameter.

- `name` This is the text name of the parameter. This is not necessarily a unique value and exists mostly for readability.
- `guid` This is a 64-bit globally unique ID number. It must not overlap with other guids for other message types. A single guid may exist for multiple channels. 
- `channel` This is the channel to which this particular value applies. A single guid may cover multiple channels. If the parameter covers all channels, this value should be 255.
- `value` This is the value of the parameter. Any unitary type from Cap'n Proto can be used here. `Void` is used signal a request.

#### `ParamErr` ####

This is an enumerated type that is used to transmit an error if a parameter transaction fails for some reason. The values it can assume are as follows:

- `none` No error
- `invalidParamName` Invalid parameter name. Returned if the guid does not match the name.
- `invalidParamGUID` Invalid guid. Returned if the guid does not exist.
- `invalidParamValue` Invalid parameter value. Returned if the parameter is out of range. 
- `invalidParamChannel` Invalid parameter channel. Returned if the parameter has an incorrect channel.
- `accessDenied` Not currently used
- `paramSetFail` Parameter set failed. Returned if the device is unable to set the parameter value for a reason no previously listed. 
- `invalidParamType` Invalid parameter type. Returned if the parameter type sent to the device does not match the internal type. 

### Getting a Parameter ###

In order to get the current value of a given parameter, the host sends a `ParamStruct` with the name, UID, and channel of the desired parameter value of `request`, which is of type `Void`. 

The device responds either with the requested `ParamStruct` and a `ParamErr`. `ParamErr` is an enumerated type containing a variety of possible error types.

If the parameter exists, the device sends the host a `ParamStruct` for that parameter including the value.

If the parameter does not exist, the device responds with a `ParamErr` with an appropriate value. 

### Setting a Parameter ###

In order to set a parameter, the host sends the device a `ParamStruct`. The device responds with a `ParamErr`.

### Getting a List of Parameters ###

In order to get a list of parameter, the host sends a `List(ParamStruct)` containing a single empty parameter. The device responds with a `List(ParamStruct)` containing all device parameters. 

## Interrupts ##

The device sometimes needs to interrupt the host, for example, when a buffer is full and ready for reading.

Upon receiving an interrupt, the host takes whatever actions are necessary to deal with the interrupts, and then sends the `IntStruct` back to clear the interrupt. 

### Messages 

#### `IntStruct` ####

- `name` The natural language name of the interrupt.
- `guid` The globally unique 64 bit ID of the interrupt.
- `channel` The channel to which the interrupt applies. An interrupt that applies to all channels or no channel in particular fills this with the value 255.

## Buffers ##

Buffers are where the data being read into the device (via GPI or ADC) or out of the device (via GPO or DAC) are stored. Typically, buffers come in pairs so one or the other can be manipulated by the host while the other is being read from or written to by the device. 

### Messages 

#### `BufStruct`

- `ID` is a `BufID` struct containing all of the data about the buffer's identity. Its members are as follows:
	- `channels` contains a list of channel numbers addressed by this buffer. It is a `List(UInt8)`.
	- `bufNum` is the buffer number, which makes it straightforward to keep track of different buffers for the same channel list. It is a `UInt8`.
	- `rate` is the sample rate of the buffer. It is a `Float32`.
	- `startTime` is the start time of the buffer. It is a `UInt64`.
	- `size` is the size of the buffer, in samples. It is a `UInt32`. The size of the buffer in bits is equal to `size` times `resolution`.
	- `contentSize` is the number of samples currently in the buffer.
	- `resolution` is the size of each sample, in bits. It is a `UInt8`, and for the MultiSpork will be either equal to 12 (for an ADC or DAC buffer) or 1 (for a GPIO buffer).
	- `direction` is the direction that the buffer will be written. It is a `Bool` and is true for an input buffer and false for an output buffer.
	- `active` is a `Bool` that is true if the buffer is being actively read to or written from by the device and is false otherwise. 
- `contents` is a `Data` blob containing the contents of the buffer. The samples are packed together with no padding, and contains the samples from each channel called out in the channel list in a maximum density packing.

#### `BufErr` ####

This is an enumerated type with all the possible buffer errors.

- `none` No error
- `bufDoesNotExist` There is no buffer with the given channel list.
- `bufEmpty` There are no samples in the buffer. 
- `bufOverflow` Either `contentSize` is larger than `

### Getting a Buffer ###

In order to get a buffer, the host sends a `BufStruct` that is empty except for the `channels` and the `bufNum`. If that channel list corresponds to a buffer on the device, the device responds with a fully populated `BufStruct`. Otherwise, it will return a `BufErr` with an appropriate value.

### Writing a Buffer ###

In order to write a buffer, the host sends a fully populated `BufStruct`. If that buffer corresponds to a buffer on the device, the device responds with a `BufErr` with the value `none`. Otherwise, it will return an appropriate error.

### Getting a List of Buffers ###

To get a list of all valid buffers, the host transmits a `List(BufID)` containing a single empty instance of `BufID`. The device responds with a `List(BufID)` containing all buffers currently in use. 

# Multispork Configuration #

This is a list specifically of the configuration of the MultiSpork. Other devices will likely have different parameters.

## Parameters ##

### Network ###

**Name** | **GUID** | **Type** | **Permitted Values** | **Default** | **Function** | 
---------|----------|----------|----------------------|-------------|--------------|
Device Name | | String | Any string that is permissible as an internet host name | multispork\<serial number\> | This is a name to allow the user to identify different devices from a single host. This is also the network SSID in host mode |
Device IP Address | | UInt32 | Any valid IP address | 10.10.10.10 | This is the IP address of the device. In client mode, this will be populated via DHCP; otherwise, it is populated from the last value stored in NVM |
WPA2 Key | | String | Any string | none | This is the password used for logging in to the device by the host. If the device is not in host mode, it will use this password to log in to the target network. |
Target SSID | | String | Any valid SSID | none | This is the network the device attempts to log in to in client mode |
Host Mode | | Bool | | true | When true, the device functions as a WiFi access point. Otherwise, it attempts to log in to the network stored in Target SSID |

### Channel Configuration ###

**Name** | **GUID** | **Channels** | **Permitted Values** | **Default** |  **Function** |  

### Trigger ###

**Name** | **GUID** | **Permitted Values** | **Default** | **Function** | 

## Interrupts ##

## Buffers ##

The Multispork allocates a maximum of eight buffers -- two analog input buffers, two analog output buffers, two digital input buffers, and two digital output buffers. They are allocated dynamically in response to the configuration of the channels.

**Description** | **Channels** | **Function** |
