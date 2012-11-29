#include <Timer.h>
#include "MaliciousTemp.h"

configuration MaliciousTempAppC {
}
implementation {
	components MainC;
	components MaliciousTempC as App;
	components new TimerMilliC() as Timer0;
	components ActiveMessageC;
	components new AMSenderC(AM_MALICIOUSTEMP);

	App.Boot -> MainC;
	App.Timer0 -> Timer0;
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
}