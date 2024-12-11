/*------------------------------------------------------------------*/
/*     by CPU.SJC (c) 2000-4-9					    */
/*------------------------------------------------------------------*/
#include <sys/types.h>
#include <file.h>
#include <graphics.h>
#include <kernel.h>
#include <libapi.h>
#include <memory.h>
#include <DEBUG.H>
#include <PARIO.H>
#include <MEMFUNC.H>
#include <SCRFUN.H>
#include "XCARD.H"

#define OT_COUNT	2048		// 每個表項佔 20 bytes
#define PACKETMAX	1024		// 程式大概會用多少表項, < 10000
#define PACKETMAX2	(PACKETMAX * 24) // 最長的封包要 52 bytes, 此乘其平均值
GsOT	usrOT[2];			// 兩個 OT 表的主結構
GsOT_TAG  OTag[2][OT_COUNT];		// 指到各別 OT 的指標陣列
PACKET	GPUPacket[2][PACKETMAX2];	// GPU Packet work area

void dump(long addr, short len);
long testCardExist(short bu);	// 測試看 PS2 記憶片是否存在, 1=存在, 0=不存在

long	rv;
short	buid;
char	*showStr;

void main(void)
{
int	i;
char	c;
u_char	*p;

showStr = (char *) 0x1F4000;
uInitVideo(OT_COUNT, 320, 240);
prepareToShow();

// printf("\n你要讀取哪一片記憶卡 (0 or 1) :");
// c = conGetch(); 	buid = c & 1;
// printf("\n你要用哪種方式讀取 (0) PS2 測試");
// c = conGetch();
// if (c == 0x30) {	// Test PS2 card
	c = 0;
	for (i=0;i < 2000;i ++) {
		rv = testCardExist(1);
		printf("test card %d: return %lX\n", buid, rv);
		if (rv < 0) c ++;
		if (c > 200) i = 9999;
		}
//	}
dump(0xFC00, 0x100);
printf("\nBye ! Bye !\n");
SysReset();
}

// ------------- dunp -----------------
void dump(long addr, short len)
{
u_char *p, i;

p = (u_char *) addr;
do {
  sprintf(showStr, "%08lX-", addr);  printf(showStr);
  for (i=0;i < 16;i ++) {
        sprintf(showStr, "%02X ", p[i]);
        printf(showStr);
        }
  for (i=0;i < 16;i ++) {
        showStr[i] = p[i];
        if (p[i] < 32) showStr[i] = '.';
        }
  showStr[16] = 10;  showStr[17] = 0;
  printf(showStr);
  len -= 16;
  addr += 16;
  p += 16;
  } while (len > 0);
}
