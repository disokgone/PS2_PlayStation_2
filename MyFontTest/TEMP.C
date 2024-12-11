//---------------------------------------------------------------------------
void show16x15(TObject *Sender)
{
char    *p;
int     chr;

p = Edit1->Text.c_str();
if (u8(*p) > 0x8E) chr = *((u16 *) p);       	// 直接取得中文字
else {  // 取得內碼數值
    chr = StrToInt("$" + Edit1->Text);
    chr = swap16(chr);          // 須高低值互換
    }
p = getFont16(chr);     // 取得點陣資料
if (p == NULL) return;  // is ASCII, 或非中文字, 或無此中文字型
dispBlock(p, 16, 15);   // 以 16x15 的方式來畫出方塊
// free(p);
}
//---------------------------------------------------------------------------
void show24x24(TObject *Sender)
{
char    *p;
int     chr;

p = Edit1->Text.c_str();
if ((u8)(*p) > 0x8E) chr = *((u16 *) p);     	// 直接取得中文字
else {  // 取得內碼數值
    chr = StrToInt("$" + Edit1->Text);
    chr = swap16(chr);          // 須高低值互換
    }
p = getFont24(chr);     // 取得點陣資料
if (p == NULL) return;  // is ASCII, 或非中文字, 或無此中文字型
dispBlock(p, 24, 24);   // 以 24x24 的方式來畫出方塊
// free(p);
}
