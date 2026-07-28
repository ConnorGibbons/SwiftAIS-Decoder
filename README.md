Decodes AIS NMEA 0183 sentences into meaningful vessel data. 


\*\*Note\*\* currently a lot of the message type inits are failable. I'd like to keep it that way, but the conditions under which they fail are too strict. Oftentimes transmitters will fill garbage in spots where data is missing, and small things such as enum values being out of range will cause the initializer to fail. At some point I'll change this to just keep & flag garbage values without aborting.
