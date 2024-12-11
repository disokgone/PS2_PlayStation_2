//---------------------------------------------------------------------------
#ifndef GENERALH
#define GENERALH

int binaSearch(int *tbl, int key, int elesz, int maxNdx);
short calcScrLines(TForm *pform);           // 取得畫面可顯示的行數
char CollideMode(int a, int al, int b, int bl); // 檢查碰撞
int GetHex(char *s);                        // 從字串 s 處取得 Hex 值
void grabAddrAsCacheTable(int fh, int fofs, int allSize, int *pTable);
// 取 2048 組位址到 pTable[] 當快取 (Elf32_Rel 型態)
void MakeRelocate(char *p, int pofs, int info, int addlo, int addhi);
void MemoAdd(TMemo *mm, char *s);           // 把字串 s 加到 Memo 中
void padSpaces(char *src, int len);         // 補足空白字元

//---------------------------------------------------------------------------
#endif
