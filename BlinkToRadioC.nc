#include <Timer.h>
#include "BlinkToRadio.h"

module BlinkToRadioC {
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
			BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof (BlinkToRadioMsg)));
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->counter = counter;
			//sends a packet to node 15
			//change 15 to whatever node you would like to send it to
			if (call AMSend.send(15, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
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
		if (len == sizeof(BlinkToRadioMsg)) {
			BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
			call Leds.set(btrpkt->counter);
		}
		return msg;
	}
	
}