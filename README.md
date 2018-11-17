# fpga_mpu401
MPU-401 Implementation on FPGA. Based on the System68 CPU core by John E. Kent.

This is still very much a work-in-progress, like most of my projects. lol

I did manage to get it to capture MIDI bytes from a real MIDI keyboard, though, using a simple opto-coupler adapter on the DE1 GPIO port.

With the In-System Memory Content Viewer on Quartus, I could see the bytes being written to a buffer in the 6800 RAM,
 so it seems that part was at least working OK.

The core will need to be hooked up to an ISA bus, or to something like the ao486 core on MiSTer, then the extra logic added for that interface.

The hope is to use this for cores like ao486 or x68000, to give them a "real" MPU-401 without needing software patches.
