#ifndef MALICIOUSTEMP_H
#define MALICIOUSTEMP_H

enum {
	AM_MALICIOUSTEMP = 3,
	TIMER_PERIOD_MILLI = 30000
};

typedef nx_struct MaliciousTempMsg {
  nx_uint16_t nodeid;
  nx_uint32_t seqNO;
  nx_uint32_t counter1;
  nx_uint16_t counter2;
  nx_uint16_t counter3;
  nx_uint32_t msgrate;
  nx_uint16_t light;
} MaliciousTempMsg;

#endif
