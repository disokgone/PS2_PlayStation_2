#include <tamtypes.h>
#include <sifrpc.h>
/* 其它的 .H 檔放在 C:\PS2DEV\GCC\MYINC\FROM_TUT\ 之下 */
#include "nuputs.h"
#include "GR_1.H"
#include "hw.h"
#include "pad.h"
#include "loadmodule.h"

#if defined(ROM_PADMAN) && defined(NEW_PADMAN)
#error Only one of ROM_PADMAN & NEW_PADMAN should be defined!
#endif

#if !defined(ROM_PADMAN) && !defined(NEW_PADMAN)
#error ROM_PADMAN or NEW_PADMAN must be defined!
#endif

/*
 * Macros
 */
#define WAIT_PAD_READY(p, s) {while(padGetState((p),(s)) != PAD_STATE_STABLE) WaitForNextVRstart(1); }

// pad_dma_buf is provided by the user, one buf for each pad
// contains the pad's current state
static char padBuf[256] __attribute__((aligned(64)));
static char actAlign[6];
static int actuators;

// ------------ init pad ------------
void do_pad_init(void)
{
int i, port, slot, ret;

loadPadModules();	padInit(0);
port = 0;		slot = 0;
nprintf("PortMax: %d\n", padGetPortMax());	// PortMax: 2
nprintf("SlotMax: %d\n", padGetSlotMax(port));	// SlotMax: 1
if ((ret = padPortOpen(0, 0, padBuf)) == 0) {	// padBuf in pad.c
	nprintf("padOpenPort failed: %d\n", ret);
	k_SleepThread();
  }
    
if (!initializePad(0, 0)) {
	nprintf("pad initalization failed !\n");
	k_SleepThread();
  }
WaitForNextVRstart(1);
i = 0;
while(padGetState(port, slot) != PAD_STATE_STABLE) {
	if (i==0) {
		nprintf("Please wait, pad state != OK\n");
		i = 1;	}
	WaitForNextVRstart(1); // Perhaps a bit to long ;)
  }
if (i==1) nprintf("Pad: OK !\n");
}
// ------------ 初始化搖桿 ------------
int initializePad(int port, int slot)
{
int ret;

    while((ret=padGetState(port, slot)) != PAD_STATE_STABLE) {
	if(ret==0) { // No pad connected!
            nprintf("Pad(%d, %d) is disconnected\n", port, slot);
            return 0;
	}
	WaitForNextVRstart(1);
    }

/* InfoMode does not work with rom0:padman */
#ifndef ROM_PADMAN
    nprintf("padInfoMode: %d\n", padInfoMode(port, slot, PAD_MODECURID, 0));

    // If ExId == 0x07 => This is a dual shock controller
    if (padInfoMode(port, slot, PAD_MODECUREXID, 0) == 0) {
        nprintf("This is NOT a dual shock controller\n");
        nprintf("Did you forget to define RAM_PADMAN perhaps?\n");
        return 1;
    }
#endif
    nprintf("Enabling dual shock functions\n");

    nprintf("setMainMode dualshock (locked): %d\n", 
               padSetMainMode(port, slot, 
                              PAD_MMODE_DUALSHOCK, PAD_MMODE_LOCK));
	// 結果顯示 setMainMode dualshock (locked): 1
    WAIT_PAD_READY(port, slot);
    nprintf("infoPressMode: %d\n", padInfoPressMode(port, slot));
	// 結果顯示 infoPressMode: 0
    WAIT_PAD_READY(port, slot);        
    nprintf("enterPressMode: %d\n", padEnterPressMode(port, slot));
	// 結果顯示 enterPressMode: 0
    WAIT_PAD_READY(port, slot);
    actuators = padInfoAct(port, slot, -1, 0);
    nprintf("# of actuators: %d\n",actuators);
	// 結果顯示 # of actuators: 2
    if (actuators != 0) {
        actAlign[0] = 0;   // Enable small engine
        actAlign[1] = 1;   // Enable big engine
        actAlign[2] = 0xff;
        actAlign[3] = 0xff;
        actAlign[4] = 0xff;
        actAlign[5] = 0xff;

        WAIT_PAD_READY(port, slot);
        nprintf("padSetActAlign: %d\n", 
                   padSetActAlign(port, slot, actAlign));
    }	// 結果顯示 padSetActAlign: 1
    else {
        nprintf("Did not find any actuators.\n");
    }

    WAIT_PAD_READY(port, slot);

return 1;
}
// ------------ 載入程式 ------------
void loadPadModules(void)
{
int ret;

if ((ret =_lf_bind(0)) != 0) nprintf("_lf_bind: %d\n", ret);

// 以下為顯示的訊息 ...
// loadmodule: fname rom0:SIO2MAN args 0 arg
#ifdef ROM_PADMAN
    ret = _sifLoadModule("rom0:SIO2MAN", 0, NULL, 0);
#else
    ret = _sifLoadModule("rom0:XSIO2MAN", 0, NULL, 0);
#endif
    if (ret == 1) {	// 0 = OK, 1 = Failed
        nprintf("sifLoadModule sio failed: %d\n", ret);
        k_SleepThread();
    }    
// loadmodule: id 27, ret 0

// loadmodule: fname rom0:PADMAN args 0 arg
#ifdef ROM_PADMAN
    ret = _sifLoadModule("rom0:PADMAN", 0, NULL, 0);
#else
    ret = _sifLoadModule("rom0:XPADMAN", 0, NULL, 0);
#endif 
    if (ret == 1) {	// 0 = OK, 1 = Failed
        nprintf("sifLoadModule pad failed: %d\n", ret);
        k_SleepThread();
    }
// Pad driver. (99/11/22)
// loadmodule: id 28, ret 0
}
