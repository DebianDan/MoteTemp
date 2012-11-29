#include <Timer.h>
#include "MaliciousTemp.h"

module MaliciousTempC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;
}
implementation {
	uint16_t counter = 0;
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
		counter++;
		//call Leds.set(counter);
		if (!busy) {
			MaliciousTempMsg* btrpkt = (MaliciousTempMsg*)(call Packet.getPayload(&pkt, sizeof (MaliciousTempMsg)));
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->counter = counter;
			if (call AMSend.send(1, &pkt, 
sizeof(MaliciousTempMsg)) == SUCCESS) 
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
	
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		if (len == sizeof(MaliciousTempMsg)) {
			MaliciousTempMsg* btrpkt = (MaliciousTempMsg*)payload;
			call Leds.set(btrpkt->counter);
		}
		return msg;
	}
	
}
