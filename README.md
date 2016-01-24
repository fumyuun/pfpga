# pfpga
An FPGA in VHDL to map on an an FPGA, because recursion is fun. Currently, only two basic cells are implemented: a lut2 and lut4. A simple tool is there to evaluate boolean expressions into a programming bitstream.

	"Yo dawg, I heard you like FPGA's, so I put an FPGA on your FPGA so you can synthesize while you synthesize." - A wise person.

## bitstream generator
A tiny tool is supplied as well, which uses bison and lex to create a simple "compiler". It simply takes a C-like boolean expression from STDIN and creates a bitstream for it.

Example:

	echo "A && B" | ./parser


