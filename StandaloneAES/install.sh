#!/bin/sh

make micaz install mib510,/dev/ttyS0
java net.tinyos.tools.PrintfClient -comm serial@/dev/ttyS0:micaz

