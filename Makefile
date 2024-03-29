
URWEB := athrun jgross urweb

PROJECT := urlatex

empty :=
space := $(empty) $(empty)
colon := $(empty):$(empty)

SYSNAMES := $(shell fs sysname | tr ' ' '\n' | grep "^'.\\+'\$$" | sed s"/'//g" | tr '\n' ' ')
SYSNAME_EXTRA_LIBS := $(foreach name,$(SYSNAMES),$(wildcard $(HOME)/arch/$(name)/lib))
SYSNAME_LIBS := $(SYSNAME_LIBS)$(subst $(space),$(empty),$(addprefix $(colon),$(SYSNAME_EXTRA_LIBS)))

#HOME="/mit/jgross"
#./configure --prefix=/mit/jgross/arch/i386_deb50 LDFLAGS="-L/usr/lib64/mysql" CCARGS="-L/usr/lib64/mysql"

LD_LIBRARY_PATH := /usr/lib64/mysql:$(SYSNAME_LIBS):$(LD_LIBRARY_PATH)
LD_RUN_PATH := /usr/lib64/mysql:$(SYSNAME_LIBS):$(LD_RUN_PATH)
LDFLAGS := -L/usr/lib64/mysql

export LD_LIBRARY_PATH
export LD_RUN_PATH
export LDFLAGS
#echo "LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH\""
#CMD="$URWEB -noEmacs -protocol fastcgi -dbms sqlite -sql $PROJECT.sql -db \"dbname=$DIR/$PROJECT.db\" $PROJECT"


default: run-scripts

$(PROJECT).exe:

scripts: $(PROJECT).exe
	@echo "If you get a permission denied error, try"
	@echo "fsr sa . daemon.scripts rlidwka"
	ssh -K scripts.mit.edu "cd $(shell pwd); make local"
	/mit/scripts/bin/for-each-server pkill $(PROJECT).exe || true


local: $(PROJECT).exe
	$(URWEB) -noEmacs -protocol fastcgi $(PROJECT)
	pkill $(PROJECT).exe || true

run-scripts: scripts
	/mit/scripts/bin/for-each-server "$(shell readlink -f "$(PROJECT).exe")" || true

run-local: local
	./$(PROJECT).exe &

#athrun scripts for-each-server pkill tester.exe

clean:
	$(RM) $(PROJECT).exe

.phony: clean scripts local default run-scripts run-local
