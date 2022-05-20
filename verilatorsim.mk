VBIN ::= $(shell which verilator)
VBINDIR ::= $(shell dirname $(VBIN))
VINCDIR ::= $(VBINDIR)/../share/verilator/include
VINCDIR_DPI ::= $(VINCDIR)/vltstd

VERILATED_SRC ::= $(VINCDIR)/verilated.cpp

VERILATED_DPI_SRC ::= $(VINCDIR)/verilated_dpi.cpp

VERILATED_DEPS ::= $(VINCDIR)/verilated_dpi.h       \
                   $(VINCDIR)/verilated_dpi.cpp     \
                   $(VINCDIR)/verilated.h           \
                   $(VINCDIR)/verilatedos.h         \
                   $(VINCDIR)/verilated_imp.h       \
                   $(VINCDIR)/verilated_heavy.h     \
                   $(VINCDIR)/verilated_syms.h      \
                   $(VINCDIR)/verilated_sym_props.h \
                   $(VINCDIR)/verilated_config.h    \
                   $(VINCDIR_DPI)/svdpi.h


VERILATED_FST_C_SRC ::= $(VINCDIR)/verilated_fst_c.cpp

VERILATED_FST_C_DEPS ::= $(VINCDIR)/verilated.h \
                         $(VINCDIR)/verilated_fst_c.cpp \
                         $(VINCDIR)/verilatedos.h \
                         $(VINCDIR)/verilated_fst_c.h \
                         $(VINCDIR)/verilated_trace.h \
                         $(VINCDIR)/gtkwave/fstapi.h \
                         $(VINCDIR)/gtkwave/fastlz.c \
                         $(VINCDIR)/gtkwave/fastlz.h \
                         $(VINCDIR)/gtkwave/fastlz.c \
                         $(VINCDIR)/gtkwave/fstapi.c \
                         $(VINCDIR)/gtkwave/fst_config.h \
                         $(VINCDIR)/gtkwave/fstapi.h \
                         $(VINCDIR)/gtkwave/lz4.h \
                         $(VINCDIR)/gtkwave/lz4.c \
                         $(VINCDIR)/verilated_trace_imp.cpp \
                         $(VINCDIR)/verilated_intrinsics.h


MODEL_LIB ?= ./obj_dir/Vcore_v_mcu_testharness__ALL.a

CPP := gcc
CXX := g++
CPPFLAGS := -I$(VINCDIR) -I$(VINCDIR_DPI) -I./obj_dir -I../../../tb/uartdpi/ -DVL_TIME_CONTEXT -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=1 -DVM_TRACE_FST=1 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable -Wno-shadow
CXXFLAGS := -std=c++11 -Wall -g -fpermissive  -std=gnu++14 -O0 -g3
LDFLAGS := -lz -pthread -lutil -lelf

CF_STYLE := "{BasedOnStyle: GNU, \
              AllowShortFunctionsOnASingleLine: InlineOnly, \
              ColumnLimit: 80}"

OBJS = core_v_mcu_tb.o

.PHONY: all
all: mem_init core_v_mcu_tb.exe

core_v_mcu_tb.exe: $(OBJS) verilated.o verilated_dpi.o verilated_fst_c.o uartdpi.o $(MODEL_LIB)
	echo $(VBINDIR)
	$(CXX) $^ $(LDFLAGS) -o $@

verilated.o: $(VERILATED_SRC) $(VERILATED_DEPS) $(MODEL_LIB)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $(VERILATED_SRC)

verilated_dpi.o: $(VERILATED_DPI_SRC) $(VERILATED_DEPS) $(MODEL_LIB)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $(VERILATED_DPI_SRC)

verilated_fst_c.o: $(VERILATED_FST_C_SRC) $(VERILATED_FST_C_DEPS) $(MODEL_LIB)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $(VERILATED_FST_C_SRC)

mem_init:
	$(RM) $@
	ln -s ./mem_init $@
uartdpi.o: ../../../tb/uartdpi/uartdpi.c
	$(CXX) $(CPPFLAGS) $(CXXFLAGS)  -c -o $@ $<

# Object dependencies
core_v_mcu_tb.o: ../../../tb/core_v_mcu_tb.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	$(RM) $(OBJS) testbench.exe verilated.o verilated_fst_c.o

.PHONY: distclean
distclean: clean
	$(RM) *.vcd *.VCD *.log
