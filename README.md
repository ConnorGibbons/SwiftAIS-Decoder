** Work in Progress ** 

SwiftAIS-Decoder decodes AIS NMEA 0183 sentences into meaningful vessel data. 

Currently working on building out parsers for every AIS message type. Types 1-22 are supported at the moment.
Afterwards, I plan on making the decoder networked so it can fit into a broader ecosystem:

**Input**
Planning on adding a built in TCP-based server to receive & decode NMEA sentences from a client. (Possibly multiple clients -- looking into how this will work with sequence numbers and such)

**Output**
SwiftAIS-Decoder will eventually act as a client for servers accepting decoded information. The goal is to allow the user to build a field --> json field name / type mapping so the decoder isn't restricted to a particular output format. 

\*\*Note\*\* currently a lot of the message type inits are failable. I'd like to keep it that way, but the conditions under which they fail are too strict. Oftentimes transmitters will fill garbage in spots where data is missing, and small things such as enum values being out of range will cause the initializer to fail. At some point I'll change this to just keep & flag garbage values without aborting.


Credit to the following sites/resources I used in the process:
* https://github.com/ukyg9e5r6k7gubiekd6/gpsd/blob/master/test/sample.aivdm -> Used this to get a lot of the sample data for message type parsing tests.
- https://www.maritec.co.za/aisvdmvdodecoding -> Compared decoder output for verification
- https://www.aggsoft.com/ais-decoder.htm -> Compared decoder output for verification
- https://gpsd.gitlab.io/gpsd/AIVDM.html#_type_9_standard_sar_aircraft_position_report -> Amazing resource containing a breakdown of each AIS message type.
