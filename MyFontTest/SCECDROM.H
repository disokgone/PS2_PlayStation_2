void *get_iob(int iob_no);		// 傳回指定的 iob 檔案存取區塊位址
void *new_iob(void);			// 借一個檔案存取區塊
void rd_func(void *p);			// (僅供本程式內部 sceRead() 呼叫 !)
void sbcopy(void *src, void *dst, int len);	// in scrn1.s
int sceClose(int fd);
int sceFsInit(void);	// 對 sce file system 做 init ! (僅供本程式內部呼叫 !)
int sceLseek(int fd, int ofs, int whence);
int sceOpen(char *fn, int mode);	// 開啟檔案, 傳回值 < 1 是失敗 !
int sceRead(int fd, void *buf, int len);	// OK 傳回 0, (傳回 < 0 是失敗)

void dieHere(int a, int b, int c, int d);