# Makefile generated by BNFC.

# List of goals not corresponding to file names.

.PHONY : all clean distclean

# Default goal.

all : TestSimFirewall

# Rules for building the parser.

ErrM.hs LexSimFirewall.x PrintSimFirewall.hs ParSimFirewall.y TestSimFirewall.hs : SimFirewall.cf
	bnfc --haskell SimFirewall.cf

%.hs : %.y
	happy --ghc --coerce --array --info $<

%.hs : %.x
	alex --ghc $<

TestSimFirewall : TestSimFirewall.hs ErrM.hs LexSimFirewall.hs ParSimFirewall.hs PrintSimFirewall.hs
	ghc --make $< -o $@
	cp AbsSimFirewall.hs ErrM.hs LexSimFirewall.hs ParSimFirewall.hs PrintSimFirewall.hs SkelSimFirewall.hs ../src

# Rules for cleaning generated files.

clean :
	-rm -f *.hi *.o *.log *.aux *.dvi

distclean : clean
	-rm -f AbsSimFirewall.hs AbsSimFirewall.hs.bak ComposOp.hs ComposOp.hs.bak DocSimFirewall.txt DocSimFirewall.txt.bak ErrM.hs ErrM.hs.bak LayoutSimFirewall.hs LayoutSimFirewall.hs.bak LexSimFirewall.x LexSimFirewall.x.bak ParSimFirewall.y ParSimFirewall.y.bak PrintSimFirewall.hs PrintSimFirewall.hs.bak SharedString.hs SharedString.hs.bak SkelSimFirewall.hs SkelSimFirewall.hs.bak TestSimFirewall.hs TestSimFirewall.hs.bak XMLSimFirewall.hs XMLSimFirewall.hs.bak ASTSimFirewall.agda ASTSimFirewall.agda.bak ParserSimFirewall.agda ParserSimFirewall.agda.bak IOLib.agda IOLib.agda.bak Main.agda Main.agda.bak SimFirewall.dtd SimFirewall.dtd.bak TestSimFirewall LexSimFirewall.hs ParSimFirewall.hs ParSimFirewall.info ParDataSimFirewall.hs Makefile


# EOF
