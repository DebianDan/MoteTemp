#ifndef MALICIOUSTEMP_H
#define MALICIOUSTEMP_H

enum {
	AM_MALICIOUSTEMP = 6,
	TIMER_PERIOD_MILLI = 1000
};

typedef nx_struct MaliciousTempMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} MaliciousTempMsg;

#endif
