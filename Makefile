TOP_DIR = ../..

include $(TOP_DIR)/tools/Makefile.common

DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
SERVICE_SPEC = KmerAnnotationByFigfam.spec
SERVICE_NAME = KmerAnnotationByFigfam
SERVICE_PORT = 7105
SERVICE_URL = http://10.0.16.184:$(SERVICE_PORT)

SERVICE_DIR = kmer_annotation_figfam
SERVICE_SUBDIRS = webroot bin

SRC_SERVICE_PERL = $(wildcard service-scripts/*.pl)
BIN_SERVICE_PERL = $(addprefix $(BIN_DIR)/,$(basename $(notdir $(SRC_SERVICE_PERL))))
DEPLOY_SERVICE_PERL = $(addprefix $(TARGET)/bin/,$(basename $(notdir $(SRC_SERVICE_PERL))))

STARMAN_WORKERS = 8
STARMAN_MAX_REQUESTS = 100

ifdef DEPLOYMENT_VAR_DIR
SERVICE_LOGDIR = $(DEPLOYMENT_VAR_DIR)/services/$(SERVICE_DIR)
TPAGE_SERVICE_LOGDIR = --define kb_service_log_dir=$(SERVICE_LOGDIR)
endif

TPAGE_ARGS = --define kb_top=$(TARGET) --define kb_runtime=$(DEPLOY_RUNTIME) --define kb_service_name=$(SERVICE_NAME) \
	--define kb_service_port=$(SERVICE_PORT) --define kb_service_dir=$(SERVICE_DIR) \
	--define kb_sphinx_port=$(SPHINX_PORT) --define kb_sphinx_host=$(SPHINX_HOST) \
	--define kb_psgi=$(SERVICE_NAME).psgi \
	--define kb_starman_workers=$(STARMAN_WORKERS) \
	--define kb_starman_max_requests=$(STARMAN_MAX_REQUESTS) \
	$(TPAGE_SERVICE_LOGDIR)

default: bin compile-typespec

bin: build-libs $(BIN_PERL)

dist: 

dist-cpan: dist-cpan-client dist-cpan-service

dist-egg: dist-egg-client dist-egg-service

dist-npm: dist-nmp-client dist-npm-service

dist-java: dist-java-client dist-java-service

dist-cpan-client:
	echo "cpan client distribution not supported"

dist-cpan-service:
	echo "cpan service distribution not supported"

dist-egg-client:
	echo "egg client distribution not supported"

dist-egg-service:
	echo "egg service distribution not supported"

dist-npm-client:
	echo "npm client distribution not supported"

dist-npm-service:
	echo "npm service distribution not supported"

dist-java-client:
	echo "java client distribution not supported"

dist-java-service:
	echo "java service distribuiton not supported"

# Test Section

test: test-client test-scripts test-service
	@echo "running client and script tests"

test-client:
	# run each test
	for t in $(CLIENT_TESTS) ; do \
		if [ -f $$t ] ; then \
			$(DEPLOY_RUNTIME)/bin/perl $$t ; \
			if [ $$? -ne 0 ] ; then \
				exit 1 ; \
			fi \
		fi \
	done

test-scripts:
	# run each test
	for t in $(SCRIPT_TESTS) ; do \
		if [ -f $$t ] ; then \
			$(DEPLOY_RUNTIME)/bin/perl $$t ; \
			if [ $$? -ne 0 ] ; then \
				exit 1 ; \
			fi \
		fi \
	done

test-service:
	# run each test
	for t in $(SERVER_TESTS) ; do \
		if [ -f $$t ] ; then \
			$(DEPLOY_RUNTIME)/bin/perl $$t ; \
			if [ $$? -ne 0 ] ; then \
				exit 1 ; \
			fi \
		fi \
	done

deploy: deploy-client deploy-service

deploy-all: deploy-client deploy-service

deploy-client: compile-typespec deploy-libs deploy-scripts deploy-docs

deploy-service: build-libs deploy-libs deploy-dir deploy-service-scripts
	for templ in service/*.tt ; do \
		base=`basename $$templ .tt` ; \
		$(TPAGE) $(TPAGE_ARGS) $$templ > $(TARGET)/services/$(SERVICE_DIR)/$$base ; \
		chmod +x $(TARGET)/services/$(SERVICE_DIR)/$$base ; \
	done
	rm -f $(TARGET)/postinstall/$(SERVICE_DIR)
	ln -s ../services/$(SERVICE_DIR)/postinstall $(TARGET)/postinstall/$(SERVICE_DIR)

deploy-service-scripts:
	export KB_TOP=$(TARGET); \
	export KB_RUNTIME=$(DEPLOY_RUNTIME); \
	export KB_PERL_PATH=$(TARGET)/lib ; \
	export KB_DEPLOYMENT_CONFIG=$(TARGET)/deployment.cfg; \
	export WRAP_VARIABLES=KB_DEPLOYMENT_CONFIG; \
	for src in $(SRC_SERVICE_PERL) ; do \
		basefile=`basename $$src`; \
		base=`basename $$src .pl`; \
		echo install $$src $$base ; \
		cp $$src $(TARGET)/plbin ; \
		$(WRAP_PERL_SCRIPT) "$(TARGET)/plbin/$$basefile" $(TARGET)/services/$(SERVICE_DIR)/bin/$$base ; \
	done

deploy-dir:
	if [ ! -d $(TARGET)/services/$(SERVICE_DIR) ] ; then mkdir $(TARGET)/services/$(SERVICE_DIR) ; fi
	if [ "$(SERVICE_SUBDIRS)" != "" ] ; then \
		for dir in $(SERVICE_SUBDIRS) ; do \
		    	if [ ! -d $(TARGET)/services/$(SERVICE_DIR)/$$dir ] ; then mkdir -p $(TARGET)/services/$(SERVICE_DIR)/$$dir ; fi \
		done;  \
	fi

deploy-docs: build-docs
	-mkdir -p $(TARGET)/services/$(SERVICE_DIR)/webroot/.
	cp docs/*.html $(TARGET)/services/$(SERVICE_DIR)/webroot/.

build-docs: compile-docs
	-mkdir -p docs
	pod2html --infile=lib/Bio/KBase/$(SERVICE_NAME)/Client.pm --outfile=docs/$(SERVICE_NAME).html

compile-docs: build-libs

build-libs: compile-typespec

compile-typespec: Makefile
	compile_typespec \
		--patric \
		--psgi $(SERVICE_NAME).psgi \
		--impl Bio::KBase::$(SERVICE_NAME)::$(SERVICE_NAME)Impl \
		--service Bio::KBase::$(SERVICE_NAME)::Service \
		--client Bio::KBase::$(SERVICE_NAME)::Client \
		--py biokbase/$(SERVICE_NAME)/Client \
		--js javascript/$(SERVICE_NAME)/Client \
		--scripts scripts \
		--url $(SERVICE_URL) \
		$(SERVICE_SPEC) lib

include $(TOP_DIR)/tools/Makefile.common.rules

