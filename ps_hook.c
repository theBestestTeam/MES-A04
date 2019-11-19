/*
* Programmer          : Paul Smith & Amy Dayasundara
* Course code         : SENG2010
* Date of Submission  : 2019-11-14
* Description         : This file contains the C code for the psadA4
*                       function
*/

#include <stdio.h>
#include <stdint.h>
#include <ctype.h>
#include "stm32f3xx_hal.h"
#include "stm32f3_discovery.h"
#include "stm32f3_discovery_accelerometer.h"
#include "stm32f3_discovery_gyroscope.h"
#include "common.h"
//#include "main.c"

//global variable for game
extern volatile uint32_t gameCount;


int tilt(int hold, int target, int timer);

//int noDelay(int timer);
//  int tilt(int timer, char *range, char *target); Old version

void psadA4(int action)
{
  if(action==CMD_SHORT_HELP) return;
  if(action==CMD_LONG_HELP) {
    printf("Tilt Test\n\n"
   "This command tests new game function\n"
   );
    return;
    }

    //first parameter of game function is gathered (time player must hold position)
    uint32_t hold;
    int fetch_status;
    fetch_status = fetch_uint32_arg(&hold);
    if(fetch_status) {
      hold = 500; //defaults to 500ms
    }

    //second parameter of game function is gathered (target game number)
    uint32_t target;
    fetch_status = fetch_uint32_arg(&target);
    if(fetch_status) {
      target = 4; //defaults to light 4
    }

    //third parameter of game function is gathered (time in seconds for game duration)
    uint32_t timer;
    fetch_status = fetch_uint32_arg(&timer);
    if(fetch_status) {
      timer = 12; //defaults to 12 seconds
    }

    //game function is called with necessary parameters
    tilt(hold, target, timer);
}

ADD_CMD("psadTilt", psadA4,"Test the new tilt game function")
