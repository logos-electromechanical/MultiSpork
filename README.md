MultiSpork
==========

A wireless analog/digital multitool &amp; data recorder.

When I'm working on a mobile robotics projects, I often wish I could attach my scope, logic analyzer, or signal generator to some aspect of the 'bot without tethering it to the bench. IOW, what I need is some kind of widget that does the data acquisition on the 'bot and sends it back to a screen. Ideally, it would also have plenty of range, easy configuration, a nice interface (Saleae is my model for how this should be). 

Maxim just released a chip, the MAX 11300, that incorporates a good chunk of what's required for this. It gives you twenty channels, each of which can by ADC, DAC, or GPIO, and communicates over a fast SPI bus. Add an Atmel SAM processor (I already have the dev tools, so this is an easy decision) and a wifi module, and we're in business. Cheap wifi-only Android tablets can be had for as little as $50, so Android is the obvious choice for a host OS. 

See the wiki (https://github.com/logos-electromechanical/MultiSpork/wiki) for more info.
