#ifndef MALICIOUSTEMP_H
#define MALICIOUSTEMP_H

enum {
	AM_MALICIOUSTEMP = 3,
	TIMER_PERIOD_MILLI = 10000
};

typedef nx_struct MaliciousTempMsg {
	nx_uint16_t nodeid;
	nx_uint32_t seqNO;
	nx_uint16_t cmdNO;
	nx_uint16_t voltage;
	nx_uint16_t temp;
	nx_uint8_t power;
	nx_uint8_t groupID;
	nx_uint32_t msgrate;
	nx_uint16_t light;
} MaliciousTempMsg;

#endif
