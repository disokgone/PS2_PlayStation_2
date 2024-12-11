#include <sys/types.h>
#include <libsio.h>
#include <memory.h>
#include <memfunc.h>		// 我設計的記憶片存取函式
#include <pario.h>		// 除錯顯示用途

long testCardExist(short bu);	// 測試看 PS2 記憶片是否存在, 1=存在, 0=不存在
short sendBufData(char *p, short len);	// 送出後續 len bytes

// ----------------- 測試看 PS2 記憶片是否存在 -----------------
long testCardExist(short bu)
{
u_short *ctrl, buSel;
char	*ioBuf;
short	rtv;
char	retry, retry2;

retry2 = 7;		// fail & retry count = 7
ctrl = (u_short *) 0x1F80104A;	// SIO0_CTRL
_clr_sio0();		// 初始 sio0 狀態, Baud rate = 2 MHz
ioBuf = (char *) 0xFC00;	// 暫放資料
buSel = (bu & 1) << 13;	// 0x2000 = slot 2
_no_intr();
_set_imask(0x80);	// 致能 MEMC (SIO0) 中斷
while (retry2) {
    retry = 3;		// fail & retry count = 3
    while (retry) {
	*ctrl = 0;		// 清除先前的 SIO0 狀態
	_delay3n_2(64); 	// delay 8.9 us
	*ctrl = buSel | CR_DSRIEN | CR_DTR | CR_TXEN;	// 開始送出脈波
	rtv = mcRWxint(0x81);	// 不等待中斷, 先送出 0x81
	if (rtv >= 0) { 	// 小於零為無反應, 大於零的值才有效
//		bzero(ioBuf, 256);
		ioBuf[0] = 0x43;	ioBuf[1] = 0x15;
		ioBuf[5] = 0x15;
		rtv = sendBufData(ioBuf, 133);	// 送出後續 4 bytes
		if (rtv == mcOK) goto ok_01;
		if (rtv == badProtocol) goto bad_02;	// 速度似乎太快
		if (rtv < mcOK) goto bad_01;	// 傳輸途中有誤
		}
	retry --;
	}
bad_01:
    _clr_sio0();	// 初始 sio0 狀態
    if (rtv == badLine) rtv = notInstalled;	// 可能沒插卡, 須重試
bad_02:
    retry2 --;
    if (rtv == mcOK) retry2 = 0;	// good exit !
    }
ok_01:
_clr_sio0();		// 初始 sio0 狀態
_clr_imask(0x80);	// disable MEMC (SIO0) 中斷
_en_intr();
return(rtv);
}

// ----------------- 送出後續 len bytes -----------------
short sendBufData(char *p, short len)
{
u_short	*ctrl;
short	rtv, n;

for (n=0;n < len-1;n ++) {
	_delay3n_2(32); 		// delay 4.4 us
	rtv = mclRW(p[n]);		// 等待中斷後, 送出 p[n], 讀得 0xFF
	if (rtv < 0) return(badLine);	// 傳輸線不良
	p[n] = rtv;
	}

// 讀取最後一個 byte 的返回值
ctrl = (u_short *) 0x1F801044;
while(*ctrl & 0x80);		// 等前一字已送出
*(ctrl+3) |= 0x12;		// SIO0.Ctrl |= (CR_ERRRST+CR_DTR)
_delay3n_2(64); 		// delay 8.9 us
*((char *) 0x1F801040) = 0x55;	// 寫出最後一字
_delay3n_2(32); 		// delay 4.5 us
n = 0;
do	{
	rtv = *((short *) 0x1F801044);
	n ++;
	if (n == -2) return(mcTimeout);	// 失敗 (Time out);
	} while ((rtv & 2) == 0);	// 等最後一字
p[len-1] = *((char *) 0x1F801040);	// clear Rbuf !
return(mcOK);
}

