#include <stdio.h>
#include <tamtypes.h>
#include <kernel.h>
#include <sifcmd.h>
#include <sifrpc.h>
#include <malloc.h>
#include <string.h>
#include <mylibk.h>	// 須引用 sifrpc.h !
#include "nuputs.h"
#include "scecdrom.h"

#define		maxBufLen	1024		// 完整檔名最長 1024 bytes
#define		maxIOBno	16		// 最多可同時開啟 16 個檔案

struct t_iob
{	// 每個 iob 佔 16 bytes !
    int		data;
    int		flag;
    int		unk0;
    int		unk1;
};

static int	_init_check = 0;
struct t_iob	sysIob[maxIOBno];		// 最多可同時開啟 16 個檔案 ($1688F0, len $100)
struct t_rpc_client_data	client;		// 與 IOP 傳輸用結構
static char	rdbuf[0x60];
// -----------------------------------------------------
void *get_iob(int iob_no)
{	// 傳回指定的 iob 檔案存取區塊位址 (20006.EXE, $119B08)
if (iob_no < maxIOBno) return(&sysIob[iob_no]);
return(0);	// 不良的 iob 檔案存取區塊編號
}
// -----------------------------------------------------
void *new_iob(void)
{	// 借一個檔案存取區塊 (20006.EXE, $119A98)
struct t_iob	*iob;

DI;
iob = sysIob;
while(iob < &sysIob[maxIOBno]) {
	if (iob->flag == 0) {	// 找到空閒的 iob 可用 !
		iob->flag = 0x10000000;
		EI;
		return(iob);
		}
	iob ++;
	}
EI;
return(0);	// 無空閒的 iob 可用
}
// -----------------------------------------------------
void rd_func(void *p)
{	// 20006.EXE, $119EE0
int	*pi;
// int	*pd, i;

pi = (int *) UNCACHED_SEG(p);
if ((pi[0] > 0) && (pi[2] != 0)) sbcopy(p + 16, (void *) pi[2], pi[0]);
if ((pi[1] > 0) && (pi[3] != 0)) sbcopy((void *) pi[3], p + 80, pi[1]);
/*pd = (int *) *((int *) 0x44C000);
for (i=0;i<4;i++) pd[i] = pi[i];
*((int *) 0x44C000) = (int) (pd + 4);	*/
// dieHere(pi[0], pi[1], pi[2], pi[3]);
}
// -----------------------------------------------------
int sceClose(int fd)
{	// 20006.EXE, $119D60, 測試 OK !
struct t_iob	*iob;
int	recv, ret;

if (! _init_check) return(-1);		// 根本未初始化
iob = (struct t_iob *) get_iob(fd);
if (iob == NULL) return(-9);		// 未曾開啟此檔案
if (iob->flag == 0) return(-9);		// 未曾開啟此檔案
ret = sif_call_rpc(&client, 1, 0, &iob->data, 4, &recv, 4, NULL, 0);
if (ret < 0) return(-1);	// failed !
iob->flag = 0;	// 清成 free !
return(recv);	// 成功 !
}
// -----------------------------------------------------
int sceFsInit(void)
{	// 對 sce file system 做 init ! (僅供本程式內部呼叫 ! 20006.EXE, $119B30)
int	ret;

sif_rpc_init(0);	// 內部有檢查, 只會 init 一次 !
bzero(&client, sizeof(struct t_rpc_client_data));	// 我自加, 清成 0
do	{
	ret = sif_bind_rpc(&client, 0x80000001, 0);
	if (ret < 0) return(-1);
	if (client.server == NULL) for (ret = 0;ret < 0xF0000;ret ++);	// short delay !
	} while (client.server == NULL);

for (ret = 0; ret < maxIOBno;ret ++) sysIob[ret].flag = 0;	// clear all IOBS[] to free !
k_SifWritebackDcache(rdbuf, 0x40);	// flush D-Cache for rdbuf
_init_check = 1;	// 只須 init 一次
return(0);		// = OK !
}
// -----------------------------------------------------
int sceLseek(int fd, int ofs, int whence)
{	// 20006.EXE, $119E08, 測試 OK !
struct t_iob	*iob;
int	recv, ret, bit15;
int 	send_buf[3];

if (! _init_check) return(-1);		// 根本未初始化
iob = (struct t_iob *) get_iob(fd);
if (iob == NULL) return(-9);		// 未曾開啟此檔案
if (iob->flag == 0) return(-9);		// 未曾開啟此檔案

send_buf[0] = iob->data;
send_buf[1] = ofs;
send_buf[2] = whence;
bit15 = (iob->flag & 0x8000) ? 1 : 0;	// 取 bit 15 !
ret = sif_call_rpc(&client, 4, bit15, send_buf, 12, &recv, 4, NULL, 0);
if (ret < 0) return(-1);
if (iob->flag & 0x8000) return(0);	// failed !
return(recv);	// OK !
}
// -----------------------------------------------------
int sceOpen(char *fn, int mode)
{	// 20006.EXE, $119C08, 測試 OK !
struct t_iob	*iob;
int	lenfn, *o_mode, recv, ret;
char	*fn2;
char	fnbuf[maxBufLen + 8];

if (! _init_check) sceFsInit();		// 只須 init 一次

iob = (struct t_iob *) new_iob();	// 借一個檔案存取區塊
if (iob == NULL) return(-19);		// $119C4C

lenfn = 0;	fn2 = fnbuf + 4;	*fn2 = *fn;
while ((lenfn < maxBufLen) && (*fn != 0)) {	// 拷貝檔名
	*fn2 = *fn;		fn2 ++;		fn ++;
	lenfn ++;
	}

if (lenfn >= maxBufLen) {	// $119CA8
	lenfn = maxBufLen - 1;
	fnbuf[maxBufLen + 3] = 0;
	}
o_mode = (int *) fnbuf;
*o_mode = mode & 0x0FFFFFFF;	// 記錄開啟模式

ret = sif_call_rpc(&client, 0, 0, fnbuf, lenfn + 5, &recv, 4, NULL, 0);
if (ret < 0) return(-1);	// 下載到 IOP 時發生錯誤 !
recv = *((int *) UNCACHED_SEG(&recv));		// $119D08
if (recv < 0) {		// 開啟檔案時發生錯誤 !
	iob->flag = 0;		// 釋還此 iob 區塊
	return(recv);		// 傳回錯誤碼 (如檔案不存在, 則傳回 -1)
	}
iob->data = recv;
iob->flag |= mode;
return((iob - sysIob) >> 4);	// 傳回使用第幾個 iob !
}
// -----------------------------------------------------
int sceRead(int fd, void *buf, int len)
{	// 20006.EXE, $119F68, 可用, 傳回此次讀取的長度, 但 rd_func 的用途不清 !
struct t_iob	*iob;
int	recv, ret, uncached;
int 	send_buf[4];

if (! _init_check) return(-1);		// 根本未初始化
iob = (struct t_iob *) get_iob(fd);
if (iob == NULL) return(-9);		// 未曾開啟此檔案
if (iob->flag == 0) return(-9);		// 未曾開啟此檔案

recv = 0;
send_buf[0] = iob->data;
send_buf[1] = (int) buf;
send_buf[2] = len;
send_buf[3] = (int) rdbuf;	// read 完成時, 會在 rdbuf 內填值, 並呼叫你指定的 endfunc()

// *((int *) 0x44C000) = 0x44C004;	// for my debug !

uncached = IS_UNCACHED_SEG(iob->flag);
if (! uncached) k_SifWritebackDcache(buf, len);	// 需要 flush D-Cache !

k_SifWritebackDcache(rdbuf, 0x90);
k_SifWritebackDcache(send_buf, 0x10);

ret = sif_call_rpc(&client, 2, uncached, send_buf, 0x10, &recv, 4, rd_func, rdbuf);
if (ret < 0) return(-1);
if (iob->flag & 0x8000) return(0);	// failed ! (iob->flag = 0x10000001 is OK)
return(recv);	// OK ! (return 0)
}
// -----------------------------------------------------
int sceWrite(int fd, void *buf, int len)
{
struct t_iob	*iob;
int	i, mode, recv, ret, rem;
int 	send_buf[3];

if (! _init_check) return(-1);		// 根本未初始化
iob = (struct t_iob *) get_iob(fd);
if (iob == NULL) return(-9);		// 未曾開啟此檔案
if (iob->flag == 0) return(-9);		// 未曾開啟此檔案

send_buf[0] = iob->data;
send_buf[1] = (int) buf;
send_buf[2] = len;

rem = ((int) buf & 15) ? (((int) buf >> 4) << 4) + 16 - (int) buf : 0 ;	// 如未切齊 16 byte, 則 rem 為餘數
if (IS_UNCACHED_SEG(buf) == 0) k_SifWritebackDcache(buf, len);	// 是快取區內, 須先更新快取
mode = ((int) buf & 0x8000) ? 1 : 0 ;		// 取得 buf 的 bit 15
if (len < rem) rem = len;	// 總長度便是這不足 16 byte 的餘數 !
if (rem) { // 自己搬這些剩餘不足 16 byte 的資料
	buf = UNCACHED_SEG(buf);
	for (i = 0;i < rem;i ++) send_buf[16+i] = *((char *) buf + i);
	}
ret = sif_call_rpc(&client, 3, mode, send_buf, 0x20, &recv, 4, NULL, 0);
if (ret < 0) return(-1);
if (iob->flag & 0x8000) return(0);	// failed !
return(recv);	// OK !
}
