#include <sys/types.h>
#include <file.h>
#include <kernel.h>
#include <libapi.h>
#include <libetc.h>
#include "AR2.H"

int waitPad(int last);

// #define	du01	"%04X-";
// #define	du02	"%02X ";
// #define	du03	"Now at $%08X";

#define	du01	0x10975C	// At File $F75C
#define	du02	0x109764	// At File $F764
#define	du03	0x10976C	// At File $F764, Free from $109778

extern	int	dumploc, dumpmode, x, xlen, *pkt, *ctrl;
// --------------------------------------
int waitPad(int last)
{
int	pad;

do	{
	pad = readPad(0);
	if (pad == 0) pad = last;	// 無按鍵
	} while (pad == last);
return(pad);
}
// --------------------------------------
void doDump(void)
{
char	buf[64];
int	adr, i, j, k, y;
u_char	*addr;
char	c;

drawFrame(pkt, x, 8, xlen, 256, 0);	// CLS
adr = ((int) addr) & 0xFFFF;
if (dumpmode == 0) {
    for (j=2, y=20;j < 25;j ++) {
	sprintf(buf, (char *) du01, adr);
	for (i=0, k=5;i < 8;i ++, k += 3) sprintf(buf+k, (char *) du02, *addr++);
	drawBitMap(pkt, 12, y, buf);	// 印出結果
	adr += 8;	y += 10;
	}
    }
else {
    fillchar(buf, 0x20, 48);
    for (j=2, y=20;j < 25;j++) {
	sprintf(buf, (char *) du01, adr);
	for (i=0;i<24;i++) {
		c = *addr ++;
		if ((c < 32) || (c > 0x7A)) c = '.';
		buf[5+i] = c;
		}
    	drawBitMap(pkt, 12, y, buf);	// 印出結果
	adr += 24;	y += 10;
	}
    }
sprintf(buf, (char *) du03, dumploc);
drawBitMap(pkt, 12, 270, buf);	// 印出處理結果
}
// --------------------------------------
