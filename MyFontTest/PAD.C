/*********************************************************************
 * Pad library functions
 * Quite easy rev engineered from util demos..
 * Find any bugs? Mail me: pukko@home.se
 *                      -pukko
 *
 *  rev 1.2 (20020113)
 */


#include <tamtypes.h>
#include <kernel.h>
#include <sifrpc.h>
#include <sifcmd.h>
#include <stdlib.h>
#include <string.h>
#include <mylibk.h>
#include "pad.h"


/*
 * Slightly different behaviour if using "rom0:padman" or something newer
 * (such as "rom0:xpadman" on those machines that have it)
 * User must define which is used
 */ 
#if defined(ROM_PADMAN) && defined(NEW_PADMAN)
#error Only one of ROM_PADMAN & NEW_PADMAN should be defined!
#endif

#if !defined(ROM_PADMAN) && !defined(NEW_PADMAN)
#error ROM_PADMAN or NEW_PADMAN must be defined!
#endif



/*
 * Defines
 */
#ifdef ROM_PADMAN

#define PAD_BIND_RPC_ID1 0x8000010f
#define PAD_BIND_RPC_ID2 0x8000011f

#define PAD_RPCCMD_OPEN         0x80000100	// scePadPortInit or scePadPortOpen
// #define PAD_RPCCMD_		0x80000101	// (invalid)
// #define PAD_RPCCMD_		0x80000102	// scePadInfoAct
// #define PAD_RPCCMD_		0x80000103	// scePadInfoComb
// #define PAD_RPCCMD_		0x80000104	// scePadInfoMode
#define PAD_RPCCMD_SET_MMODE    0x80000105	// scePadSetMainMode
#define PAD_RPCCMD_SET_ACTDIR   0x80000106	// scePadSetActDirect
#define PAD_RPCCMD_SET_ACTALIGN 0x80000107	// scePadSetActAlign
#define PAD_RPCCMD_GET_BTNMASK  0x80000108	// scePadGetButtonMask
#define PAD_RPCCMD_SET_BTNINFO  0x80000109	// scePadSetButtonInfo
#define PAD_RPCCMD_SET_VREF     0x8000010a	// scePadSetVrefParam
#define PAD_RPCCMD_GET_PORTMAX  0x8000010b	// scePadGetPortMax
#define PAD_RPCCMD_GET_SLOTMAX  0x8000010c	// scePadGetSlotMax
#define PAD_RPCCMD_CLOSE        0x8000010d	// scePadPortClose
#define PAD_RPCCMD_END          0x8000010e	// scePadClose or scePadEnd
// #define PAD_RPCCMD_		0x8000010f	// scePadInit2
// #define PAD_RPCCMD_		0x80000110	// scePadGetConnection
// #define PAD_RPCCMD_		0x80000111	// scePadGetModVersion
// #define PAD_RPCCMD_		0x80000112	// ?
// #define PAD_RPCCMD_		0x80000113	// scePadSetWarningLevel

#define PAD_RPCCMD_INIT         0x00000000  /* not supported */
#define PAD_RPCCMD_GET_CONNECT  0x00000000  /* not supported */
#define PAD_RPCCMD_GET_MODVER   0x00000000  /* not supported */

#else

#define PAD_BIND_RPC_ID1 0x80000100
#define PAD_BIND_RPC_ID2 0x80000101

// 在 *(u32 *)(&buffer[0]) = 如下值;
#define PAD_RPCCMD_OPEN         0x01
#define PAD_RPCCMD_SET_MMODE    0x06
#define PAD_RPCCMD_SET_ACTDIR   0x07
#define PAD_RPCCMD_SET_ACTALIGN 0x08
#define PAD_RPCCMD_GET_BTNMASK  0x09
#define PAD_RPCCMD_SET_BTNINFO  0x0A
#define PAD_RPCCMD_SET_VREF     0x0B
#define PAD_RPCCMD_GET_PORTMAX  0x0C
#define PAD_RPCCMD_GET_SLOTMAX  0x0D
#define PAD_RPCCMD_CLOSE        0x0E
#define PAD_RPCCMD_END          0x0F
#define PAD_RPCCMD_INIT         0x10
#define PAD_RPCCMD_GET_CONNECT  0x11
#define PAD_RPCCMD_GET_MODVER   0x12
#define PAD_RPCCMD_SetWarningLevel	0x14	// from \ps2dis099.023\rpcdef\80000100PADMAN.txt
#endif



/*
 * Types
 */

struct pad_state
{
    int open;
    unsigned int port;
    unsigned int slot;
    struct pad_data *padData;
    unsigned char *padBuf;
};

#ifdef ROM_PADMAN
// rom0:padman has only 64 byte of pad data
struct pad_data 
{
    unsigned int frame;		// ofs 0
    unsigned char state;	// ofs 4
    unsigned char reqState;	// ofs 5
    unsigned char ok;		// ofs 6
    unsigned char unkn7;	// ofs 7
    unsigned char data[32];	// ofs 8
    unsigned int length;	// ofs 40
    unsigned int unkn44;	// ofs 44
    unsigned int unkn48;
    unsigned int unkn52;
    unsigned int unkn54;
    unsigned int unkn60;
};
#else
struct pad_data 
{
    unsigned char data[32]; // 0, length = 32 bytes
    unsigned int unkn32;    // not used??
    unsigned int unkn36;    // not used??
    unsigned int unkn40;    // byte 40  not used??
    unsigned int unkn44;    // not used?? 44
    unsigned char actData[32]; // actuator (6x4?) 48
    unsigned short modeTable[4];  // padInfo   80
    unsigned int frame;     // byte 88, u32 22
    unsigned int unkn92;    // not used ??
    unsigned int length;    // 96
    unsigned char modeOk;   // padInfo  100 Dunno about the name though...
    unsigned char modeCurId; // padInfo    101
    unsigned char unkn102;  // not used??
    unsigned char unknown;  // unknown
    unsigned char nrOfModes;   // padInfo   104
    unsigned char modeCurOffs; // padInfo   105
    unsigned char nrOfActuators;     // act  106
    unsigned char unkn107[5];  // not used??
    unsigned char state;    // byte 112
    unsigned char reqState; // byte 113
    unsigned char ok;       // padInfo  114
    unsigned char unkn115[13];  // not used??
};
#endif



/*
 * Pad variables etc.
 */

static const char padStateString[8][16] = {"DISCONNECT", "FINDPAD", 
                                           "FINDCTP1", "", "", "EXECCMD", 
                                           "STABLE", "ERROR"};
static const char padReqStateString[3][16] = {"COMPLETE", "FAILED", "BUSY"};

static int padInitialised = 0;

// pad rpc call
static struct t_rpc_client_data padsif[2] __attribute__((aligned(64)));
static char buffer[128] __attribute__((aligned(16)));

/* Port state data */
static struct pad_state PadState[8][2];


/*
 * Local functions
 */

/*
 * Santas little helper
 */
inline static void
nopdelay()
{
    int i;
    
    for (i=0; i<0x10000; i++) {
        asm ( "nop\n nop\n nop\n nop\n nop\n" );
    }
}

/*
 * Common helper
 */
static struct pad_data*
padGetDmaStr(int port, int slot)
{
    struct pad_data *pdata;
    
    pdata = PadState[port][slot].padData;    
    k_SifWritebackDcache(pdata, 256);

    if(pdata[0].frame < pdata[1].frame) {
        return &pdata[1];
    }
    else {
        return &pdata[0];
    }
}
    
            
/*
 * Global functions
 */

/*
 * Functions not implemented here
 * padGetFrameCount() <- dunno if it's useful for someone..
 * padInfoComb() <- see above
 * padSetVrefParam() <- dunno
 */

/*
 * Initialise padman
 * a = 0 should work..
 */
int
padInit(int a)
{
    int ver;
    int i;

    if(padInitialised)
        return 0;

    padsif[0].server = NULL;
    padsif[1].server = NULL;
    
    do {
        if (sif_bind_rpc(&padsif[0], PAD_BIND_RPC_ID1, 0) < 0) {
            return -1;
        }
        nopdelay();
    } while(!padsif[0].server);

    do {
        if (sif_bind_rpc(&padsif[1], PAD_BIND_RPC_ID2, 0) < 0) {
            return -3;
        }
        nopdelay();
    } while(!padsif[1].server);

    ver = padGetModVersion();
    // If you require a special version of the padman, check for that here

    for(i = 0; i<8; i++)
    {
        PadState[i][0].open = 0;
        PadState[i][0].port = 0;
        PadState[i][0].slot = 0;
        PadState[i][1].open = 0;
        PadState[i][1].port = 0;
        PadState[i][1].slot = 0;
    }

#ifndef ROM_PADMAN
    *(u32 *)(&buffer[0])=PAD_RPCCMD_INIT;
    if (sif_call_rpc( &padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
        return -1;
#endif
    padInitialised = 1;
    return 0;
    
}


/*
 * End all pad communication (not tested)
 */
int
padEnd()
{	// slps_200.03, $22A7A8

    int ret;
    

    *(u32 *)(&buffer[0])=PAD_RPCCMD_END;
    
    if (sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
        return -1;

    ret = *(int *)(&buffer[12]);
    if (ret == 1) {
        padInitialised = 0;
    }
    
    return ret;
}
    

/*
 * The user should provide a pointer to a 256 byte (2xsizeof(struct pad_data))
 * 64 byte aligned pad data area for each pad port opened
 *
 * return != 0 => OK
 */
int
padPortOpen(int port, int slot, void *padArea)
{	// slps_200.03, $22A830

    int i;
    struct pad_data *dma_buf = (struct pad_data *)padArea;
    
    // Check 64 byte alignment
    if((u32)padArea & 0x3f) {
        //        scr_printf("dmabuf misaligned (%x)!!\n", dma_buf);
        return 0;
    }
    
    for (i=0; i<2; i++) {                // Pad data is double buffered
        memset(dma_buf[i].data, 0xff, 32); // 'Clear' data area
        dma_buf[i].frame = 0;
        dma_buf[i].length = 0;
        dma_buf[i].state = PAD_STATE_EXECCMD;
        dma_buf[i].reqState = PAD_RSTAT_BUSY;
        dma_buf[i].ok = 0;
        dma_buf[i].length = 0;
#ifndef ROM_PADMAN
        dma_buf[i].unknown = 0; // Should be cleared in newer padman
#endif
    }
    
// 以下的呼叫會送到 rom0:padman.$626C 處理 !
    *(u32 *)(&buffer[0]) = PAD_RPCCMD_OPEN;
    *(u32 *)(&buffer[4]) = port;
    *(u32 *)(&buffer[8]) = slot;
    *(u32 *)(&buffer[16]) = (u32)padArea;
    
    if(sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
    {
        return 0;
    }

    PadState[port][slot].open = 1;
    PadState[port][slot].padData = padArea;
    PadState[port][slot].padBuf = *(char **)(&buffer[20]);

    return *(u32 *)(&buffer[12]);
}


/*
 * not tested :/
 */
int
padPortClose(int port, int slot)
{

    int ret;    

    *(u32 *)(&buffer[0]) = PAD_RPCCMD_END;
    *(u32 *)(&buffer[4]) = port;
    *(u32 *)(&buffer[8]) = slot;
    *(u32 *)(&buffer[16]) = 1;
    
    ret = sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0);
    
    if(ret < 0)
        return ret;
    else {
        PadState[port][slot].open = 0;
        return *(int *)(&buffer[12]);
    }
}


/*
 * Read pad data
 * Result is stored in 'data' which should point to a 32 byte array
 */
unsigned char
padRead(int port, int slot, struct padButtonStatus *data)
{

    struct pad_data *pdata;
    
    pdata = padGetDmaStr(port, slot);
    
    memcpy(data, pdata->data, pdata->length);
    return pdata->length;
}


/*
 * Get current pad state
 * Wait until state == 6 (Ready) before trying to access the pad
 */
int
padGetState(int port, int slot)
{	// slps_200.03 ($22AA78)
    struct pad_data *pdata;
    unsigned char state;
    

    pdata = padGetDmaStr(port, slot);
    
    state = pdata->state;    

    if (state == PAD_STATE_STABLE) { // Ok
        if (padGetReqState(port, slot) == PAD_RSTAT_BUSY) {
            return PAD_STATE_EXECCMD;
        }
    }    
    return state;
}


/*
 * Get pad request state
 */
unsigned char
padGetReqState(int port, int slot)
{
    
    struct pad_data *pdata;
            
    pdata = padGetDmaStr(port, slot);
    return pdata->reqState;
}


/*
 * Set pad request state (after a param setting)
 */
int
padSetReqState(int port, int slot, int state)
{

    struct pad_data *pdata;
            
    pdata = padGetDmaStr(port, slot);
    pdata->reqState = state;
    return 1;
}


/*
 * Debug print functions
 * uh.. these are actually not tested :)
 */
void
padStateInt2String(int state, char buf[16])
{

    if(state < 8) {
        strcpy(buf, padStateString[state]);
    }
}

void
padReqStateInt2String(int state, char buf[16])
{
    if(state < 4)
        strcpy(buf, padReqStateString[state]);
}


/*
 * Returns # slots on the PS2 (usally 2)
 */
int
padGetPortMax(void)
{
    
    *(u32 *)(&buffer[0])=PAD_RPCCMD_GET_PORTMAX;
    
    if (sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
        return -1;

    return *(int *)(&buffer[12]);
}


/*
 * Returns # slots the port has (usually 1)
 * probably 4 if using a multi tap (not tested)
 */
int
padGetSlotMax(int port)
{
    
    *(u32 *)(&buffer[0])=PAD_RPCCMD_GET_SLOTMAX;
    *(u32 *)(&buffer[4])=port;
    
    if (sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
        return -1;

    return *(int *)(&buffer[12]);
}


/*
 * Returns the padman version
 * NOT SUPPORTED on module rom0:padman
 */
int
padGetModVersion()
{
#ifdef ROM_PADMAN
    return 1; // Well.. return a low version #
#else
    
    *(u32 *)(&buffer[0])=PAD_RPCCMD_GET_MODVER;
    
    if (sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
        return -1;

    return *(int *)(&buffer[12]);
#endif
}


/*
 * Get pad info (digital (4), dualshock (7), etc..)
 * ID: 3 - KONAMI GUN
 *     4 - DIGITAL PAD
 *     5 - JOYSTICK
 *     6 - NAMCO GUN
 *     7 - DUAL SHOCK
 *
 * NOT SUPPORTED on module rom0:padman
 */
int
padInfoMode(int port, int slot, int infoMode, int index)
{

    struct pad_data *pdata;

    pdata = padGetDmaStr(port, slot);    

    if (pdata->ok != 1)
        return 0;
    if (pdata->reqState == PAD_RSTAT_BUSY)
        return 0;

#ifdef ROM_PADMAN
    return 0;  // Can't do anything useful here :(
#else
    switch(infoMode) {
    case PAD_MODECURID:
        if (pdata->modeCurId == 0xF3)
            return 0;
        else
            return (pdata->modeCurId >> 4);
        break;

    case PAD_MODECUREXID:
        if (pdata->modeOk == pdata->ok)
            return 0;
        return pdata->modeTable[pdata->modeCurOffs];
        break;

    case PAD_MODECUROFFS:
        if (pdata->modeOk != 0)
            return pdata->modeCurOffs;
        else
            return 0;
        break;

    case PAD_MODETABLE:
        if (pdata->modeOk != 0) {
            if(index == -1) {
                return pdata->nrOfModes;
            }
            else if (pdata->nrOfModes < index) {
                return pdata->modeTable[index];
            }
            else {
                return 0;
            }
        }
        else
            return 0;
        break;
    }
    return 0;
#endif
}


/*
 * mode = 1, -> Analog/dual shock enabled; mode = 0 -> Digital  
 * lock = 3 -> Mode not changeable by user
 */
int
padSetMainMode(int port, int slot, int mode, int lock)
{
    
    *(u32 *)(&buffer[0])=PAD_RPCCMD_SET_MMODE;
    *(u32 *)(&buffer[4])=port;
    *(u32 *)(&buffer[8])=slot;
    *(u32 *)(&buffer[12])=mode;
    *(u32 *)(&buffer[16])=lock;
        
    if (sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
        return 0;
	// sif_call_rpc() 傳回值放在 buffer[20]
    if (*(int *)(&buffer[20]) == 1) {
        padSetReqState(port, slot, PAD_RSTAT_BUSY);
    }
    return *(int *)(&buffer[20]);    
}


/*
 * Check if the pad has pressure sensitive buttons
 */
int
padInfoPressMode(int port, int slot)
{
    int mask;
    
    mask = padGetButtonMask(port, slot);
    
    if (mask^0x3ffff) {
        return 0;
    }
    else {
        return 1;
    }
}


/*
 * Pressure sensitive mode ON
 */
int
padEnterPressMode(int port, int slot)
{
    return padSetButtonInfo(port, slot, 0xFFF);
}


/*
 * Check for newer version
 * Pressure sensitive mode OFF
 */
int
padExitPressMode(int port, int slot)
{
    return padSetButtonInfo(port, slot, 0);
    
}


/*
 *
 */
int
padGetButtonMask(int port, int slot)
{
    
    *(u32 *)(&buffer[0])=PAD_RPCCMD_GET_BTNMASK;
    *(u32 *)(&buffer[4])=port;
    *(u32 *)(&buffer[8])=slot;
        
    if (sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
        return 0;

    return *(int *)(&buffer[12]);
}


/*
 *
 */
int
padSetButtonInfo(int port, int slot, int buttonInfo)
{
    int val;

    *(u32 *)(&buffer[0])=PAD_RPCCMD_SET_BTNINFO;
    *(u32 *)(&buffer[4])=port;
    *(u32 *)(&buffer[8])=slot;
    *(u32 *)(&buffer[12])=buttonInfo;
        
    if (sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
        return 0;

    val = *(int *)(&buffer[16]);

    if (val == 1) {
        padSetReqState(port, slot, PAD_RSTAT_BUSY);
    }
    return *(int *)(&buffer[16]);
}


/*
 * Get actuator status for this controller
 * If padInfoAct(port, slot, -1, 0) != 0, the controller has actuators
 * (i think ;) )
 *
 * NOT SUPPORTED with module rom0:padman
 */
unsigned char
padInfoAct(int port, int slot, int actuator, int cmd)
{

    struct pad_data *pdata;
    
    pdata = padGetDmaStr(port, slot);

#ifdef ROM_PADMAN
    if (pdata->ok != 1)
        return 0;
    
    if (actuator == -1)
        return 2; // Assume we have a dual shock controller

    // Feels like this is the best we can do :(
    return 0;

#else    
    if (pdata->ok != 1)
        return 0;
    if (pdata->modeOk < 2)
        return 0;
    if (actuator >= pdata->nrOfActuators)
        return 0;

    if (actuator == -1)
        return pdata->nrOfActuators;   // # of acutators?

    if (cmd >= 4)
        return 0;

    return pdata->actData[actuator*4+cmd];
#endif
}


/*
 * Initalise actuators. On dual shock controller:
 * actAlign[0] = 0 enables 'small' engine
 * actAlign[1] = 1 enables 'big' engine
 * set actAlign[2-5] to 0xff (disable)
 */
int
padSetActAlign(int port, int slot, char actAlign[6])
{
    int i;
    char *ptr;

    *(u32 *)(&buffer[0])=PAD_RPCCMD_SET_ACTALIGN;
    *(u32 *)(&buffer[4])=port;
    *(u32 *)(&buffer[8])=slot;

    ptr = (char *)(&buffer[12]);    
    for (i=0; i<6; i++)
        ptr[i]=actAlign[i];
        
    if (sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
        return 0;

    if (*(int *)(&buffer[20]) == 1) {
        padSetReqState(port, slot, PAD_RSTAT_BUSY);
    }
    return *(int *)(&buffer[20]);    
}


/*
 * Set actuator status
 * On dual shock controller, 
 * actAlign[0] = 0/1 turns off/on 'small' engine
 * actAlign[1] = 0-255 sets 'big' engine speed
 */
int
padSetActDirect(int port, int slot, char actAlign[6])
{
    int i;
    char *ptr;

    *(u32 *)(&buffer[0])=PAD_RPCCMD_SET_ACTDIR;
    *(u32 *)(&buffer[4])=port;
    *(u32 *)(&buffer[8])=slot;

    ptr = (char *)(&buffer[12]);    
    for (i=0; i<6; i++)
        ptr[i]=actAlign[i];
        
    if (sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
        return 0;

    return *(int *)(&buffer[20]);	// 1= OK, 0= Error !
}


/*
 * Dunno about this one.. always returns 1?
 * I guess it should've returned if the pad was connected..
 *
 * NOT SUPPORTED with module rom0:padman
 */
int
padGetConnection(int port, int slot)
{
#ifdef ROM_PADMAN
    return 1;
#else

    *(u32 *)(&buffer[0])=PAD_RPCCMD_GET_CONNECT;
    *(u32 *)(&buffer[4])=port;
    *(u32 *)(&buffer[8])=slot;
        
    if (sif_call_rpc(&padsif[0], 1, 0, buffer, 128, buffer, 128, 0, 0) < 0)
        return -1;

    return *(int *)(&buffer[12]);
#endif
}
