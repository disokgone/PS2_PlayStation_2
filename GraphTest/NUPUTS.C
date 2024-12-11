/*
 * NapLink EE printf example
 *
 * for use with Gustavo Scotti's psx2lib-1.0b
 */

#include <stdlib.h>
#include <tamtypes.h>
#include <sifcmd.h>
#include <sifrpc.h>
#include <kernel.h>
#include <stdarg.h>
#include <string.h>

int sif_bind_rpc( struct t_rpc_client_data *client, int rpc_number, int mode);
int sif_call_rpc( struct t_rpc_client_data *client, int rpc_number, int mode, \
        void *send, int ssize, void *receive, int rsize, \
        void (*end_function)( void *), void *end_param);
int vsnprintf (char *str, size_t sz, const char *format, va_list args);


#define NPM_PUTS     0x01
#define RPC_NPM_USER 0x014d704e

static struct t_rpc_client_data cd;
static int rpcSema;
static int putsInited = 0;

static int putsInit(void)
{
    unsigned int i;
    struct t_sema sp;
    
    sp.init_count = 0;
    sp.max_count = 1;
    sp.option = 0;
    rpcSema = k_CreateSema(&sp);

    while(1) {
	if (sif_bind_rpc(&cd, RPC_NPM_USER, 0) < 0) {
	    while(1);
	}
	if (cd.server != 0) break;
	i = 0x10000;
	while(i--);
    }
    
    k_SignalSema(rpcSema);

    putsInited = 1;

    return 0;
}

static char putsBuff[512] __attribute__ ((aligned(16)));

int nputs(char *buffer)
{
    int i = strlen(buffer) + 1;
    int ret = 0;

    if (!putsInited)
	putsInit();

    k_WaitSema(rpcSema);

    while(i > 0) {

	if (i >= 511) {
	    memcpy(putsBuff, buffer, 511);
	    putsBuff[511] = 0;
	    i -= 511;
	    buffer += 511;
	} else {
	    memcpy(putsBuff, buffer, i);
	    i = 0;
	}

	ret = sif_call_rpc(&cd, NPM_PUTS, 0, putsBuff, 512, putsBuff, 512, 0, 0);
	
	if (ret != 0)
	    break;
    }

    k_SignalSema(rpcSema);

    if (ret != 0)
	return ret;
    else
	return 1;
}

int nprintf(char *format, ...)
{
    static char buff[4096];
    va_list args;
    int rv;

    va_start(args, format);
    rv = vsnprintf(buff, 4096, format, args);
    nputs(buff);

    return rv;
}

/* int main()
{
    sif_rpc_init(0);

    npmPrintf("NapLink EE printf test\n");
    npmPrintf("ADK / Napalm 2001\n");

    while(1);
    return 0;
} */
