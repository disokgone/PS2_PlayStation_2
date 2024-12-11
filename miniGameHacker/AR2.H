int *Ar2Sys(void);				// $10E998
// 傳回 AR2 的系統變數區 = $16B5E8

void *beginPacket(void *pkt, void *ctrl);	// $110088

void drawBitMap(void *pkt, int x, int y, char *str);	// $1144D8
// 堆疊須加留 32 bytes !

void drawFrame(void *pkt, int x, int y, int xlen, int ylen, int stat);	// $100558
// stat = [AR2Sys + $140] = 0, 7C, 7E, 80 ..
void *fillchar(void *buf, u_char value, int len);	// $11EFA0

void loadRunELF_Program(int loadProg, int killFunc);	// $0C0E68
// loadProg = 1 表示要載入程式, 0 為只秀出 PS2 logo
// killFunc = 0 表示要保留 AR2 的功能, 1 則會毀棄之 (如讀取光碟能力)

void *malloc(int length);	// $1211D0
void messageBox3(char *s1, char *s2, char *s3);		// $107098

int readPad(int type);		// $10E9E0
// type 大多是 0, 偶有 1

int sceCdDiskReady(long cdromNo);	// $11C8A8
// cdromNo = 0, 傳回值為 cdrom0 狀態

int sceCdSearchFile(void *buf32, char *fileName);	// $11C8C8
// buf32 = 32 bytes 暫用緩衝區, 常如堆疊頂端
// fileName 不含有 "cdrom0:", 如 "\SYSTEM.CNF;1"

char *ustrcpy(char *dest, char *src);		// $11F0F8
int ustrlen(char *str);		// $11F130
char *ustrncpy(char *dest, char *src, int len);	// $11F160
// 傳回 dest 指標
