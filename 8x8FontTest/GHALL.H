#define NORMATTR	0x40	// 正常文字屬性
#define FONT256 0x40000 	// 8x8.FON start at here !
#define CLUTEMP 0x40FE0 	// temp used to setup COLORs[16]
#define TEXTBUF 0x80000 	// SCREEN BUFFER (32x30) start at here !
#define PKTBUF	0xA0000 	// PACKET BUFFER (32x30x20) start at here !
#define TEMPBUFF 0xC0000	// For expanding bitmap !
#define CHINESEBIN	0x044000	// my Chinese Binary file !

// u_long (* PadParse)(long keyValue);	   // deal with pad keys ..
// 本程式定義 PadParse 傳回 High 16 bit 可供程式判斷是否結束執行
// 本程式定義 PadParse 傳回 Low 16 bit 可供程式判斷是否執行重畫畫面程式
// void (* Redraw)(void);		   // 重畫畫面程式
