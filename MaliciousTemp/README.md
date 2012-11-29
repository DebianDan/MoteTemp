MaliciousTemp
=============

The task was to develop a malicious sensor node that fooled the LSAP temperature network into accepting false information.
This code is to be programmed on a TelosB Motes with a CC2420 radio in tinyos2.1.0 using nesC to hack a sensor network and inject false temperature readings at a predifed rate (1 message per 900 secs) which is configurable in the code.

Usage
====

Install on a sensor node to whcih will send out false temperature readings to PeopleNet that “fools” the LSAP. 

command is "make telosb install,<nodeID> bsl,/dev/ttyUSB0"
where <nideID> is generally which room you are trying to send a false reading from


