.code16                  #generate 16-bit code
.text                    #executable code location
     .globl _start;

_start:                  #code entry point

     #print letter 'H' onto the screen
     movb $'H' , %al
     movb $0x0e, %ah
     int  $0x10

     #print letter 'e' onto the screen
     movb $'e' , %al
     movb $0x0e, %ah
     int  $0x10

     #print letter 'l' onto the screen
     movb $'l' , %al
     movb $0x0e, %ah
     int  $0x10

     #print letter 'l' onto the screen
     movb $'l' , %al
     movb $0x0e, %ah
     int  $0x10

     #print letter 'o' onto the screen
     movb $'o' , %al
     movb $0x0e, %ah
     int  $0x10

     #print letter ',' onto the screen
     movb $',' , %al
     movb $0x0e, %ah
     int  $0x10

     #print space onto the screen
     movb $' ' , %al
     movb $0x0e, %ah
     int  $0x10

     #print letter 'W' onto the screen
     movb $'W' , %al
     movb $0x0e, %ah
     int  $0x10

     #print letter 'o' onto the screen
     movb $'o' , %al
     movb $0x0e, %ah
     int  $0x10

     #print letter 'r' onto the screen
     movb $'r' , %al
     movb $0x0e, %ah
     int  $0x10

     #print letter 'l' onto the screen
     movb $'l' , %al
     movb $0x0e, %ah
     int  $0x10

     #print letter 'd' onto the screen
     movb $'d' , %al
     movb $0x0e, %ah
     int  $0x10

     . = _start + 510      #mov to 510th byte from 0 pos
     .byte 0x55            #append boot signature
     .byte 0xaa            #append boot signature 
