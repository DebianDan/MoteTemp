#include <Timer.h>
#include "MaliciousTemp.h"

module MaliciousTempC {
	uses interface Boot;
	uses interface Timer<TMilli> as Timer0;
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
		seqNO++;  //increment the seqNO everytime a packet is sent
		if (!busy) {
			MaliciousTempMsg* btrpkt = (MaliciousTempMsg*)(call Packet.getPayload(&pkt, sizeof (MaliciousTempMsg)));
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->seqNO = seqNO;						
			btrpkt->counter1 = 0x817;
			btrpkt->counter2 = 0x3;
			btrpkt->counter3 = 0x726;
			btrpkt->msgrate = 0x384;
			btrpkt->light = 0x12;
			
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(MaliciousTempMsg)) == SUCCESS) 
			{
			  busy = TRUE;
			}
		}
	}
	
	event void AMSend.sendDone(message_t* msg, error_t error) {
		if (&pkt == msg) {
			busy = FALSE;
		}
	}
	
}
