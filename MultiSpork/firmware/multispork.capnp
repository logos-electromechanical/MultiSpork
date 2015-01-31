struct ParamStruct {
	name @0 :Text;				# name of the parameter
	guid @1 :UInt64;			# UID of the parameter
	channel @2 :UInt8;			# channel to which the parameter applies (255 for all or none)
	value :union {				# value of the parameter
		switch @3 :Bool;
		signed8 @4 :Int8;
		signed16 @5 :Int16;
		signed32 @4 :Int32;
		signed64 @5 :Int64;
		unsigned8 @6 :UInt8;
		unsigned16 @7 :UInt16;
		unsigned32 @8 :UInt32;
		unsigned64 @9 :UInt64;
		floatNum @10 :Float32;
		doubleNum @11 :Float64;
		stringVal @12 :Text;
		request @13 :Void;
	}
}
	
enum ParamErr {
	none @0;
	invalidParamName @1;
	invalidParamGUID @2;
	invalidParamValue @3;
	invalidParamChannel @4;
	accessDenied @5;
	paramSetFail @6;
	invalidParamType @7;
}

struct IntStruct {
	name @0 :Text;			# name of the interrupt
	guid @1 :UInt64;		# interrupt UID
	channel @2 :UInt8;		# channel that generated the interrupt (255 if no channel)
}

struct BufID {
	channels @0 :List(UInt8);	# The device channel that the buffer either comes from or is intended for. 
	bufNum @7 :Uint8;			# The buffer number (allows multiple buffers for a single channel)
	rate @1 :Float32;			# The sample rate of the buffer. 
	startTime @2 :UInt64;		# The start time of the buffer, in microseconds since the epoch.
	size @3 :UInt32;			# Allocated size of the buffer, in samples
	contentSize @6 :UInt32;		# The number of samples currently in the buffer
	resolution @4 :UInt8;		# Size of a sample, in bits
	direction @5 :Bool;			# True for input buffer, false for output
	active @8 :Bool;			# Is the buffer currently being read from or written to?
}

struct BufStruct {
	ID @0 :BufID;				# The identity of the buffer
	contents @1 :Data;			# The data to be encoded
}

enum BufErr {
	none @0;
	bufDoesNotExist @1;
	bufEmpty @2;
	bufOverflow @3;
	bufWriteFail @4;
	invalidBufType @5;
}