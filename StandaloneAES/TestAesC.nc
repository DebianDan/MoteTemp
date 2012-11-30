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
 * @author Bo Zhu
 */

#include "printf.h"

module TestAesC
{
  uses {
    interface Boot;
    interface SplitControl as AesControl;
    interface Encrypt;
    interface Leds;
  }
}

implementation
{
  // example from FIPS 197
  uint8_t aes_key[16] = {
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
  };

  uint8_t aes_plaintext[16] = {
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
    0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF,	
  };

  // the ciphertext should be 
  // 69 c4 e0 d8 6a 7b 04 30 d8 cd b7 80 70 b4 c5 5a
  uint8_t aes_ciphertext[16] = {0};


  event void Boot.booted() {
    //power up the cc2420 chip
    call AesControl.start();
  }

  event void AesControl.startDone(error_t err) {
    error_t error;

    do {
      error = call Encrypt.setKey((uint8_t *)aes_key);
    } while (SUCCESS != error);
  }

  event void Encrypt.setKeyDone(uint8_t * key) {
    error_t error;

    if ((uint8_t *)aes_key != key) {
      return;
    }

    do {
      error = call Encrypt.putPlain((uint8_t *)aes_plaintext, (uint8_t *)aes_ciphertext);
    } while (SUCCESS != error);
    return;
  }

  event void Encrypt.getCipher(uint8_t * plain, uint8_t * cipher) {
    uint8_t i;

    if ((uint8_t *)aes_plaintext != plain) {
      return;
    }

    //if want to change key, should call clrKey first
    call Encrypt.clrKey((uint8_t *)aes_key);
    call AesControl.stop();

    printf("key    =");
    for (i = 0; i <= 15; i++) {
      printf(" %02X", aes_key[i]);
    }
    printf("\nplain  =");
    for (i = 0; i <= 15; i++) {
      printf(" %02X", aes_plaintext[i]);
    }
    printf("\ncipher =");
    for (i = 0; i <= 15; i++) {
      printf(" %02X", aes_ciphertext[i]);
    }
    printf("\n");
    printfflush();

    return;
  }

  event void AesControl.stopDone(error_t err) {
    return;
  }
}
