# ----------------------------------------------------------------------------
# - Psymake Makefile
# ----------------------------------------------------------------------------
SRC	=H

ASM		= asmpsx
CC		= ccpsx
LINK		= psylink

# ----------------------------------------------------------------------------
# Add NTSC definition to compile for NTSC (undefined for PAL).
# Add TESTING definition for debug information while playing the movie.
# Add FIND_VLCBUF definition to find maximum runlevel.
# Define to compile final version. If defined removes all pollhosts, set 2MB
# and ramsize. Else use pollhosts and 8MB for development.

CCOPTS		= -O3 -comments-c++ -fasm -Xo$001c0000 -DFINAL
CMOPTS		= -O2 -comments-c++ -c -DFINAL
ASMOPTS 	= /l /c
LINKOPTS	= /m /c /g
LINKLIBS	= -lPARIO.lib -lMEMC.lib -lXSJC01.lib

# Define to compile with debug.
#CCOPTS = -Wunused -comments-c++ -c -g -I.. -I. -DDEBUG

# ----------------------------------------------------------------------------
OBJS	= $(SRC).o
# ----------------------------------------------------------------------------
all:
	$(CC) $(CCOPTS) $(LINKOPTS) $(SRC).c -o $(SRC).cpe,$(SRC).sym $(LINKLIBS)
# ----------------------------------------------------------------------------
