/*********************************************************************
 * Sif functions for module (.irx) loading
 * Quite easy rev engineered from util demos..
 * These functions are not in any way complete or really tested!
 *                      -pukko
 */

#include <tamtypes.h>
#include <sifrpc.h>
#include <sifcmd.h>
#include <string.h>
#include <mylibk.h>
#include "loadmodule.h"

static struct t_rpc_client_data _lf __attribute__((aligned(16)));
static int _lf_initialized = 0;
// sifLoadModule rpc call var's
static char _senddata[512] __attribute__((aligned(16)));
static char _recvdata[512] __attribute__((aligned(16)));


int
_lf_bind(int arg0)
{	// file $20006.EXE (PS2 loc. $11BD58)

    bzero(&_lf, sizeof(_lf));
    
    if(_lf_initialized) {
        return 0;
    }
    
    if (sif_bind_rpc(&_lf, 0x80000006, 0) < 0) {
        return -1;
    }
    
    if(_lf.server == NULL) {
        return -1;
    }
    
    _lf_initialized = 1;
    
    return 0;
}

int
_sifLoadModule(char *moduleName, int a, void *b, int c)
{	// file $20006.EXE (PS2 loc. $11BE00)
    
    strncpy(&_senddata[8], moduleName, 252);
    _senddata[259] = 0x00;
    _senddata[260] = 0x00;
    *(u32*)(&_senddata[0]) = 0x00000000; // (store word)

    if (sif_call_rpc(&_lf, c, 0, &_senddata, 512, &_recvdata, 4, 0, 0) < 0) {
        return -1;
    }

    /* TODO: Finish this rev.. b is always 0, but...
     *    if(b==0) {
     *    }
     *    else {
     *        
     *    }
     */
    return *(int *)(&_recvdata[0]);
}


