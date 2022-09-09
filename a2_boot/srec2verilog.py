#!/usr/bin/python
import sys, getopt, struct, time


def help () :
    print ('Quickstart help: srec2verilog.py -i <input.srec> -o <outputfile> -m <boot.mem>')
    
def main (argv) :
    try :
        opts, args = getopt.getopt(argv, "i:o:m:",[])
    except getopt.GetoptError :
        help()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h' :
            help();
            sys.exit()
        elif opt == '-i' :
            infilename = arg
        elif opt == '-o' :
            outfilename = arg
        elif opt == '-m' :
            memfilename = arg
    try:
        infile = open(infilename,'r')
        outfile = open(outfilename,'w')
        memfile = open(memfilename,'w')
    except:
        print ('Error: Input file not found\n', infilename)
        help()
        sys.exit(2)
    sys.stdout = outfile
    element = int(0);
    print ("module a2_bootrom")
    print(" #(")
    print(" parameter ADDR_WIDTH=32,")
    print(" parameter DATA_WIDTH=32")
    print(" )")
    print(" (")
    print(" input logic 		  CLK,")
    print(" input logic 		  CEN,")
    print(" input logic [ADDR_WIDTH-1:0]  A,")
    print(" output logic [DATA_WIDTH-1:0] Q")
    print(" );")
    print(" logic [31:0] 		  value;")
    print(" assign Q = value;")
    print(" always @(posedge CLK) begin")
    print("  case (A)")
    for line in infile :
        recordtype = line[:2]
        if recordtype == 'S3' :
            bytecount = int(line[2:4],16)
            address = line[4:12]
            dwords = []
            for i in range (int((bytecount - 5) / 4)) :
                dword = []
                for j in range (8) :
                    dword.append(line[(19-j)+(i)*8])
                dword[0], dword[1] = dword[1], dword[0]
                dword[2], dword[3] = dword[3], dword[2]
                dword[4], dword[5] = dword[5], dword[4]
                dword[6], dword[7] = dword[7], dword[6]
                dataInHex = "".join(dword)
                print ("  ",element,": value <= 32'h","".join(dword),";",sep="")
                sys.stdout = memfile
                print (dataInHex)
                sys.stdout = outfile
                element = element + int(1);
    print ("  default: value <= 0;")
    print("   endcase")
    print("  end")
    print("endmodule    ")
    infile.close()
    outfile.close()

if __name__ == "__main__" :
    main (sys.argv[1:])
          
def PrintException():
  exc_type, exc_obj, tb = sys.exc_info()
  f = tb.tb_frame
  lineno = tb.tb_lineno
  filename = f.f_code.co_filename
  linecache.checkcache(filename)
  line = linecache.getline(filename, lineno, f.f_globals)
  print ('Exception in ({}, Line {} "{}"): {}'.format(filename, lineno,line.strip(),exc_obj))
