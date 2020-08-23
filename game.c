/* generate 16 bit code                                                 */
__asm__(".code16gcc\n");
/* jump to main function or program code                                */
__asm__("jmpl $0x0000, $main\n");

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

void printChar(const char c) {
          __asm__ __volatile__ (
               "int $0x10" : : "a"(0x0e00 | c), "b"(0x0007)
          );
}

/* function to get a keystroke from the keyboard                        */
/* input ah = 0x00                                                      */
/* input al = 0x00                                                      */
/* interrupt: 0x10                                                      */
/* we use this function to hit a key to continue by the                 */
/* user                                                                                    */
int getch() {
    int key = 0;
     __asm__ __volatile__ ("xorw %ax, %ax");
     __asm__ __volatile__ ("int $0x16" : "=r" (key));
     return key;
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

void drawSnake() {
	int i = 0;
	unsigned char color = 10;

	int s_x = MAX_COLS/2;
	int s_y = MAX_ROWS/2;
	int s_size = 10;

	int key = 0;
	for(;;) {
	  initEnvironment();
          for(i = 0; i < s_size; i++) {
               drawPixel(color, s_x + i, s_y);
          }
	  key = getch();
	  key = (key >> 8);
	  switch(key) {
		  case 0x4D:
			s_x++;
			break;
		  case 0x4B:
			s_x--;
			break;
		  case 0x48:
			s_y--;
			break;
		  case 0x50:
		  	s_y++;
			break;
	  }
	}
}

/* function is boot code and it calls the below functions               */
/* print a message to the screen to make the user hit the               */
/* key to proceed further and then once the user hits then              */
/* it displays rectangles in the descending order                       */
void main() {
     printString("Now in bootloader...hit a key to continue\n\r");
     getch();
     initEnvironment();
     drawSnake();
}
