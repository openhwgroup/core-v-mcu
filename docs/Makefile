

# Directory where generated md files go
AUTO_MD_DIR=auto-docs
CSV_MIRROR_DIR=csv-mirror/

FOO=$(shell find ../rtl -name '*.csv' -exec mkdir -p ${CSV_MIRROR_DIR} \; -exec cp {} ${CSV_MIRROR_DIR} \;)
$(info ${FOO})
SRCS=$(shell find ../rtl -name '*.csv' -print)
$(info ${SRCS})
MD_FILES:=$(addprefix ${AUTO_MD_DIR}/,$(notdir $(SRCS:.csv=.md)))
$(info ${MD_FILES})

INSTALL_DIR:="../../core-v-mcu-cli-test/doc"

all:    doc

clean:
				rm ${MDFILES}
				(cd sphinx-source; make clean)
				
install:
				cp -r sphinx-source/_build/html ${INSTALL_DIR}

doc:    ${MD_FILES}
				make -f make-sphinx.mk html
				

${AUTO_MD_DIR}/%.md : ${CSV_MIRROR_DIR}/%.csv
			@mkdir -p ${AUTO_MD_DIR}
			@python3 ../util/ioscript.py\
				--soc-defines ../rtl/includes/pulp_soc_defines.sv\
				--reg-def-csv $<\
				--reg-def-md $@
