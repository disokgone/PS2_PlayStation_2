#include <sys/types.h>
#include <libetc.h>
#include <libsio.h>

#define MAXKEYCNT	32

void StartSIOKBD(void);
void StopSIOKBD(void);
void sio_read();
void init_sio();

u_char	keyshow=0, keycnt=0, keyline[MAXKEYCNT];

void StartSIOKBD(void)
{
ResetCallback();
init_sio();
Sio1Callback(sio_read);
}

void StopSIOKBD(void)
{
StopCallback();
DelSIO();
}

void init_sio(void)
{
_sio_control(1,1,CR_RXIEN|CR_RXEN|CR_TXEN|CR_RTS|CR_DTR); //set interrupt factor
_sio_control(1,2,MR_SB_00|MR_CHLEN_8|MR_BR_16);
_sio_control(1,3,72338);	// 2073600 / 28 = 74057 bps

printf("%X\n",_sio_control(0,0,0));
printf("%X\n",_sio_control(0,1,0));
printf("%X\n",_sio_control(0,2,0));
printf("%08lX\n",_sio_control(0,3,0));
}


void sio_read(void)
{
char c;

if (_sio_control(0,0,0) & SR_RXRDY) {
	c = _sio_control(0,4,0);
	if (keyshow) printf("> %02X ", c);
	keyline[keycnt++] = c;
	if (keycnt > MAXKEYCNT) keycnt = 0;
	}
_sio_control(2,1,0);	// clear interrupt flag
}
