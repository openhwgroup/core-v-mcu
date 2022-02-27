#!/usr/bin/python3
import linecache
import sys
import time
print (sys.version)
import serial
import pygame
import pygame.gfxdraw
import os
'''
A Python class implementing KBHIT, the standard keyboard-interrupt poller.
Works transparently on Windows and Posix (Linux, Mac OS X).  Doesn't work
with IDLE.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as 
published by the Free Software Foundation, either version 3 of the 
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

'''

# Windows
if os.name == 'nt':
    import msvcrt

# Posix (Linux, OS X)
else:
    import sys
    import termios
    import atexit
    from select import select


class KBHit:

    def __init__(self):
        '''Creates a KBHit object that you can call to do various keyboard things.
        '''

        if os.name == 'nt':
            pass

        else:

            # Save the terminal settings
            self.fd = sys.stdin.fileno()
            self.new_term = termios.tcgetattr(self.fd)
            self.old_term = termios.tcgetattr(self.fd)

            # New terminal setting unbuffered
            self.new_term[3] = (self.new_term[3] & ~termios.ICANON & ~termios.ECHO)
            termios.tcsetattr(self.fd, termios.TCSAFLUSH, self.new_term)

            # Support normal-terminal reset at exit
            atexit.register(self.set_normal_term)


    def set_normal_term(self):
        ''' Resets to normal terminal.  On Windows this is a no-op.
        '''

        if os.name == 'nt':
            pass

        else:
            termios.tcsetattr(self.fd, termios.TCSAFLUSH, self.old_term)


    def getch(self):
        ''' Returns a keyboard character after kbhit() has been called.
            Should not be called in the same program as getarrow().
        '''

        s = ''

        if os.name == 'nt':
            return msvcrt.getch().decode('utf-8')

        else:
            return sys.stdin.read(1)


    def getarrow(self):
        ''' Returns an arrow-key code after kbhit() has been called. Codes are
        0 : up
        1 : right
        2 : down
        3 : left
        Should not be called in the same program as getch().
        '''

        if os.name == 'nt':
            msvcrt.getch() # skip 0xE0
            c = msvcrt.getch()
            vals = [72, 77, 80, 75]

        else:
            c = sys.stdin.read(3)[2]
            vals = [65, 67, 66, 68]

        return vals.index(ord(c.decode('utf-8')))


    def kbhit(self):
        ''' Returns True if keyboard character was hit, False otherwise.
        '''
        if os.name == 'nt':
            return msvcrt.kbhit()

        else:
            dr,dw,de = select([sys.stdin], [], [], 0)
            return dr != []



#initialization and open the port

#possible timeout values:
#    1. None: wait forever, block call
#    2. 0: non-blocking mode, return immediately
#    3. x, x is bigger than 0, float allowed, timeout block call
#usage hserial <COM2>

if (len(sys.argv) <  2):
    print ("Usage:", sys.argv[0], "[/dev/ttyUSB0], [115200], [logfile.txt]")
ser = serial.Serial()
ser.port = "/dev/ttyUSB0"
logfile = 'logfile.txt'
if (len(sys.argv) > 1 ) :
    ser.port = sys.argv[1] 
ser.baudrate = 115200
if (len(sys.argv) > 2 ) :
    ser.baudrate = sys.argv[2]
if (len(sys.argv) > 3):
    logfile = sys.argv[3]
ser.bytesize = serial.EIGHTBITS #number of bits per bytes
ser.parity = serial.PARITY_NONE #set parity check: no parity
ser.stopbits = serial.STOPBITS_ONE #number of stop bits
#ser.timeout = None          #block read
ser.timeout = 1            #block read for  
#ser.timeout = 2              #timeout block read
ser.xonxoff = False     #disable software flow control
ser.rtscts = False     #disable hardware (RTS/CTS) flow control
ser.dsrdtr = False       #disable hardware (DSR/DTR) flow control
ser.writeTimeout = 0     #timeout for write

try: 
   ser.open()

except Exception as e:
  print ("error open serial port: " + str(e))
  exit()

def turn_on_display(size) :
  color = (200,200,200)
  if (size == 320):
          screen = pygame.display.set_mode((324,244))
          pygame.display.set_caption('324x244 image from Arnold')
  else:
          screen = pygame.display.set_mode((96,96))
          pygame.display.set_caption('96x96 image from Arnold')

  screen.fill(color)
  #pygame.draw.rect(screen,(0,255,0),[114,64,92,114],2)
  pygame.display.flip()

  return screen

def render_line(fld,screen):
  #print(fld)
  #print(fld[1])
  #print(fld[2])
  y = int(fld[1],10)
  offset = int(fld[2],10)
  count = len(fld) - 3
  #print(y)
  #print(offset)
  #print(len(fld))
  #print(count)
  for x in range (0, count):
    color = (int(fld[x+3],16) * 16 ,int(fld[x+3],16)* 16,int(fld[x+3],16)* 16)
    pygame.gfxdraw.pixel(screen,x+offset,y,color)
  if (y == 239) :
    pygame.draw.rect(screen,(0,255,0),[122,74,96,96],2)
  pygame.display.flip()
  
def PrintException():
  exc_type, exc_obj, tb = sys.exc_info()
  f = tb.tb_frame
  lineno = tb.tb_lineno
  filename = f.f_code.co_filename
  linecache.checkcache(filename)
  line = linecache.getline(filename, lineno, f.f_globals)
#  print 'Exception in ({}, Line {} "{}"): {}'.format(filename, lineno,line.strip(),exc_obj)
       
if ser.isOpen():
  try:
    ser.flushInput() #flush input buffer, discarding all its contents
    ser.flushOutput()#flush output buffer, aborting current output
    pygame.init
    kb = KBHit()
    print ("Ready to Program SPI")
    log = open(logfile,'w') # open file for logging overwite
    print ("Logging to", logfile)
#    print("Hit 'c' to toggle camera display, or ESC to exit")
#    print("    'C' single 96x96, 'V' single 320x240")
    while True :
        try:
            if kb.kbhit() :
                c = kb.getch()
                if c== 'V' :
                    c = str.encode('V')
                    ser.write(c)
                elif c == 'C' :
                    c = str.encode('C')
                    ser.write(c)
                elif c == 'c' :
                    c = str.encode('c')
                    ser.write(c)
                elif ord(c) == 27: #Esc
                    c = str.encode('Q')
                    ser.write(c)
            x = ser.read_until(b'\n')
            if x[0:3] == b'ExIt' :
                log.close()
                exit()
            if (len(x) > 0) and (len(x.decode().split()) > 0) :
                bitstream = x.decode().split()
                #print(bitstream[0])
                if bitstream[0] == "ScReEn96":
                    disp = turn_on_display(96)
                elif bitstream[0] == "ScReEn320":
                    disp = turn_on_display(320)
                elif bitstream[0] == "ImAgE" :
                    render_line(bitstream,disp)

                elif bitstream[0] == "Load":
                    
                    count = 0
                    ser.flushInput() #flush input buffer, discarding all its contents
                    ser.flushOutput() #flush output buffer, aborting current outp
                    filesize = os.path.getsize(bitstream[1])
                    bits = open(bitstream[1],'rb')
                    print ('Downloading '+str(filesize)+' bytes from '+bitstream[1])
                    ser.write(b'\163'+filesize.to_bytes(4,'little'))
                    ser.timeout = None # blocking reads
                    byte = ser.read(1)
                    time.sleep(1)
                    byte = bits.read(32)
                    count = 0
                    while (byte != b'') :
                        count = count + 32
                        byte = b'\103'+byte
                        ser.write(byte)
                        byte = ser.read(1)
                        byte = bits.read(32)
                    bits.close()
                    byte = b'\172\172\172\172\172'
                    ser.write(byte)
                    ser.timeout = 1 # blocking reads
                    print("Download complete", count, "Bytes loaded")
                else :
                    try:
                        print (x.decode()[:-1])
                        log.write(x.decode())
                        log.flush()
                    except Exception as e1:
                        print ("error communicating.2: " + str(e1))
                        continue
                   
        except Exception as e1:
            print ("error communicating.3: " + str(e1))
            print (x)
            continue
    ser.close()

  except Exception as e1:
    PrintException()
    print ("error communicating...: " + str(e1))
 
  except KeyboardInterrupt:
    pass

else:
    print ("cannot open serial port ")
