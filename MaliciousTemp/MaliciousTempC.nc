#include <Timer.h>
#include "MaliciousTemp.h"

module MaliciousTempC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface Timer<TMilli> as Timer1;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
}
implementation {
	uint32_t seqNO = 1;   //Start the Sequence number at 1
	bool busy = FALSE;
	message_t pkt;

	event void Boot.booted() {
		call AMControl.start();
	}
	
	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
		  call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
		}
		else {
		  call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}

	event void Timer0.fired() {
		seqNO++;  				//increment the seqNO everytime a packet is sent
		call Leds.set(7); 			//turn on all the LEDS when a packet it sent
		call Timer1.startOneShot(2000);  //keep the leds on for 2 seconds
		if (!busy) {
			MaliciousTempMsg* btrpkt = (MaliciousTempMsg*)(call Packet.getPayload(&pkt, sizeof (MaliciousTempMsg)));
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->seqNO = seqNO;						
			btrpkt->cmdNO = 99;
			btrpkt->voltage = 0x7BB;
			btrpkt->temp = 0x7BB;  //71.6 Farenheit
			btrpkt->power = 25;
			btrpkt->groupID = 0x26;
			btrpkt->msgrate = 10;
			btrpkt->light = 6;
			
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(MaliciousTempMsg)) == SUCCESS) 
			{
			  busy = TRUE;
			}
		}
		
	}
	
	event void Timer1.fired() {
		//when timer expires turn the LEDS off
		call Leds.set(0); 
	}
	
	event void AMSend.sendDone(message_t* msg, error_t error) {
		if (&pkt == msg) {
			busy = FALSE;
		}
	}
	
}
