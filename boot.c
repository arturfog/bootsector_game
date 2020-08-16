__asm__(".code16\n");
__asm__("jmpl $0x0000, $main\n");

// based on: https://www.codeproject.com/Articles/664165/Writing-a-boot-loader-in-Assembly-and-C-Part

#define MAX_COLS     320 /* maximum columns of the screen               */
#define MAX_ROWS     200 /* maximum rows of the screen                  */

/* function to print string onto the screen                             */
/* input ah = 0x0e                                                      */
/* input al = <character to print>                                      */
/* interrupt: 0x10                                                      */
/* we use interrupt 0x10 with function code 0x0e to print               */
/* a byte in al onto the screen                                         */
/* this function takes string as an argument and then                   */
/* prints character by character until it founds null                   */
/* character                                                            */
void printString(const char* pStr) {
     while(*pStr) {
          __asm__ __volatile__ (
               "int $0x10" : : "a"(0x0e00 | *pStr), "b"(0x0007)
          );
          ++pStr;
     }
}

/* function to get a keystroke from the keyboard                        */
/* input ah = 0x00                                                      */
/* input al = 0x00                                                      */
/* interrupt: 0x10                                                      */
/* we use this function to hit a key to continue by the                 */
/* user                                                                                    */
void getch() {
     __asm__ __volatile__ (
          "xorw %ax, %ax\n"
          "int $0x16\n"
     );
}

/* function to print a colored pixel onto the screen                    */
/* at a given column and at a given row                                 */
/* input ah = 0x0c                                                      */
/* input al = desired color                                             */
/* input cx = desired column                                            */
/* input dx = desired row                                               */
/* interrupt: 0x10                                                      */
void drawPixel(unsigned char color, int col, int row) {
     __asm__ __volatile__ (
          "int $0x10" : : "a"(0x0c00 | color), "c"(col), "d"(row)
     );
}

/* function to clear the screen and set the video mode to               */
/* 320x200 pixel format                                                 */
/* function to clear the screen as below                                */
/* input ah = 0x00                                                      */
/* input al = 0x03                                                      */
/* interrupt = 0x10                                                     */
/* function to set the video mode as below                              */
/* input ah = 0x00                                                      */
/* input al = 0x13                                                      */
/* interrupt = 0x10                                                     */
void initEnvironment() {
     /* clear screen                                                    */
     __asm__ __volatile__ (
          "int $0x10" : : "a"(0x03)
     );
     __asm__ __volatile__ (
          "int $0x10" : : "a"(0x0013)
     );
}

/* function is boot code and it calls the below functions               */
/* print a message to the screen to make the user hit the               */
/* key to proceed further and then once the user hits then              */
/* it displays rectangles in the descending order                       */
void main() {
     printString("Now in bootloader...hit a key to continue\n\r");
     getch();
     initEnvironment();
}
