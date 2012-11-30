/*
 * Copyright (c) 2008, Shanghai Jiao Tong University
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in
 *   the documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Shanghai Jiao Tong University nor the
 *   names of its contributors may be used to endorse or promote
 *   products derived from this software without specific prior
 *   written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
 
 /**
 * @author Dan Tucholski
 */

#include <Timer.h>
#include "printf.h"
#include "MaliciousTempAES.h"

module MaliciousTempC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface Timer<TMilli> as Timer1;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Encrypt;
}
implementation {
	uint16_t seqNO = 0;   //Start the Sequence number at 1
	bool busy = FALSE;
	message_t pkt;
	
	// example from FIPS 197
	uint8_t aes_key[16] = {
		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
		0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
	};
	
	uint8_t aes_ciphertext[16] = {0};

	event void Boot.booted() {
		call AMControl.start();
	}
	
	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
			//set the AES key
			do {
				error = call Encrypt.setKey((uint8_t *)aes_key);
			} while (SUCCESS != error);
		}
		else {
		  call AMControl.start();
		}
	}
	
	event void Encrypt.setKeyDone(uint8_t * key) {
		//start timer after the key is set
		call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
	}

	event void AMControl.stopDone(error_t err) {
	}

	event void Timer0.fired() {
		error_t error;
		//if the key isn't correct then break
		if ((uint8_t *)aes_key != key) {
		  return;
		}
		
		  uint8_t aes_plaintext[16] = {
			seqNO >> 2, seqNO, 0x00, 0x00, 0x08, 0x17, 0x00, 0x03, 
			0x07, 0x26, 0x00, 0x00, 0x03, 0x84, 0x00, 0x12
		  };
		
		do {
		  error = call Encrypt.putPlain((uint8_t *)aes_plaintext, (uint8_t *)aes_ciphertext);
		} while (SUCCESS != error);

		seqNO++;  	//increment the seqNO everytime a packet is sent
		
		if (!busy) {
			MaliciousTempMsg* btrpkt = (MaliciousTempMsg*)(call Packet.getPayload(&pkt, sizeof (MaliciousTempMsg)));
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->zero = 0x00;
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
		call Leds.set(7); 			//turn on all the LEDS when a packet it sent
		call Timer1.startOneShot(2000);  //keep the leds on for 2 seconds
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
