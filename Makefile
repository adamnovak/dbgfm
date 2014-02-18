PACKAGE=dbgfm
JAVA_PACKAGE=uk.ac.sanger.$(PACKAGE)

# Programs
SGA=sga

# Options
CXXFLAGS=-g -O3 -fPIC

# Directories
prefix=/usr/local
bindir=$(prefix)/bin
includedir=$(prefix)/include
libdir=$(prefix)/lib
pkgincludedir=$(includedir)/$(PACKAGE)
# Where to find JDK's /include for Java bindings
javaincludedir=$(JAVA_HOME)/include
# Where to find platform-specific JNI things
javaplatformincludedir=$(javaincludedir)/linux

# Programs and libraries to build
PROGRAMS=dbgfm bwtdisk-prepare
LIBRARIES=libdbgfm.a libdbgfm.so
# We build a version of the .so that includes SWIG-generated wrapper code.
JAVA_LIBRARIES=libdbgfmj.so
JARS=libdbgfm.jar

# Targets

all: $(LIBRARIES) $(PROGRAMS)

# Target to build Java bindings
java: $(JARS)

clean:
	rm -f $(LIBRARIES) $(JAVA_LIBRARIES) $(PROGRAMS) $(JARS) *.o *_wrap.cxx
	rm -Rf java/ jar/

install: $(PROGRAMS)
	install $(PROGRAMS) $(DESTDIR)$(bindir)
	install $(LIBRARIES) $(DESTDIR)$(libdir)
	install -d $(DESTDIR)$(pkgincludedir)
	install $(HEADERS) $(DESTDIR)$(pkgincludedir)

test: $(PROGRAMS) chr20.pp.dbgfm

uninstall:
	-cd $(DESTDIR)$(bindir) && rm -f $(PROGRAMS)
	-cd $(DESTDIR)$(libdir) && rm -f $(LIBRARIES)
	-cd $(DESTDIR)$(pkgincludedir) && rm -f $(HEADERS)
	-rmdir $(DESTDIR)$(pkgincludedir)

.PHONY: all clean install test uninstall
.DELETE_ON_ERROR:
.SECONDARY:

# Headers

HEADERS = alphabet.h bwtdisk_reader.h dbg_query.h fm_index.h \
	fm_index_builder.h fm_markers.h huffman_tree_codec.h \
	packed_table_decoder.h sga_bwt_reader.h sga_rlunit.h \
	stream_encoding.h utility.h

# Library objects

libdbgfm_OBJECTS = alphabet.o bwtdisk_reader.o dbg_query.o \
	fm_index.o fm_index_builder.o sga_bwt_reader.o utility.o

# Build libdbgfm.a

libdbgfm.a: $(libdbgfm_OBJECTS) $(HEADERS)
	$(AR) crs $@ $(libdbgfm_OBJECTS)
	
# Build libdbgfm.so

libdbgfm.so: $(libdbgfm_OBJECTS) $(HEADERS)
	$(LD) $(LDFLAGS) -shared -o libdbgfm.so  $(libdbgfm_OBJECTS)
	
# Java bindings objects
libdbgfmj_OBJECTS = $(libdbgfm_OBJECTS) fm_index_wrap.o

# Build libdbgfmj.so

libdbgfmj.so: $(libdbgfmj_OBJECTS) $(HEADERS)
	$(LD) $(LDFLAGS) -shared -o libdbgfmj.so  $(libdbgfmj_OBJECTS)
	
# Build libdbgfm.jar

libdbgfm.jar: $(JAVA_LIBRARIES)
	mkdir -p jar
	javac java/*.java -d jar
	cp $(JAVA_LIBRARIES) jar/
	jar cf $@ -C jar .

# Build dbgfm

dbgfm: main.o libdbgfm.a
	$(CXX) $(INCLUDES) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

# Build bwtdisk-prepare

bwtdisk-prepare: bwtdisk_prepare.o
	$(CXX) $(INCLUDES) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

# Tests

chr20.fa.gz:
	wget ftp://ftp.ncbi.nlm.nih.gov/genbank/genomes/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh37/Primary_Assembly/assembled_chromosomes/FASTA/chr20.fa.gz

%.pp.fa: %.fa.gz
	$(SGA) preprocess --permute $< >$@

%.bwtdisk: %.fa bwtdisk-prepare
	./run_bwtdisk.sh $<

%.dbgfm: %.bwtdisk dbgfm
	./dbgfm $*

# Build rule for SWIG files
	
%_wrap.o: %_wrap.cxx
	$(CXX) $(INCLUDES) -I$(javaincludedir) -I$(javaplatformincludedir) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -c -o $@ $^
	
%_wrap.cxx: %.i
	mkdir -p java
	swig -c++ -java -outdir java -package $(JAVA_PACKAGE) $^
	
