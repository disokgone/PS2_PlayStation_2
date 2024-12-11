// hw.h

#ifndef _HW_H_
#define _HW_H_

#ifdef __cplusplus
extern "C" {
#endif


/* not too useful, in VRHW.s */
/*void install_VRend_handler();
void remove_VRend_handler();
void WaitForNextVRend();
int TestVRend();
void ClearVRendf();	*/

/* quite useful, in VRHW.s */
void install_VRstart_handler();	// IntcID = AddIntcHandler(2, VRstart_handler, 0); (OK)
	// _EnableIntc(2);	VRcount = 0;
void remove_VRstart_handler();	// RemoveIntcHandler(2, IntcID);
void WaitForNextVRstart(int numvrs);	// VRcount = 0;  while (VRcount < numvrs) nop; (OK)
int TestVRstart();		// return(VRcount);
void ClearVRcount();		// VRcount = 0;

void SetDrawFrameBuffer(int which);	// 想作圖的畫面, which = 0 or 1
void SetCrtFrameBuffer(int which);	// 想看到的畫面, which = 0 or 1 (OK)

void resetVU0();

void qmemcpy(void *dest, void *src, int numqwords);
void dmemcpy(void *dest, void *src, int numdwords);
void wmemcpy(void *dest, void *src, int numwords);

#ifdef __cplusplus
}
#endif

#endif
