MoteTemp
========

TelosB Motes on tinyos2.1.0 using nesC to hack a sensor network to inject false temperature readings

Goal
====

Develop a malicious sensor node for the Temperature Sensing application of PeopleNet that “fools” the LSAP. 
The task was to develop a malicious sensor node that fooled the LSAP temperature network into accepting false information.

Background
==========

In the Temperature Sensing application that we have deployed at Ohio State University, one scenario is that a user can visit the PeopleNet website (http://peoplenet.cse.ohio-state.edu/peoplenet/projects/TempSense/TempSense.php) to see what the temperature in a room is presently. 
This information is streamed from a TelosB-based temperature mote which is in the room. The current implementation of the protocol between the sensor nodes and LSAP is not secure making it easy to hack.
The program will be written in TinyOS and run on a Telosb mote. 

Verification
============

To demonstrate a successful attack we will turn on the malicious mote and generate a false alarm at the LSAP which will be verified by checking the PeopleNet website.