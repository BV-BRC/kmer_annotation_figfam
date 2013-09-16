TOP_DIR = ../..

include $(TOP_DIR)/tools/Makefile.common

DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
SERVICE_SPEC = KmerAnnotationByFigfam.spec
SERVICE_NAME = KmerAnnotationByFigfam
SERVICE_PORT = 7105

SERVICE_DIR = kmer_annotation_by_figfam
SERVICE_SUBDIRS = webroot

TPAGE_ARGS = --define kb_top=$(TARGET) --define kb_runtime=$(DEPLOY_RUNTIME) --define kb_service_name=$(SERVICE_NAME) \
	--define kb_service_port=$(SERVICE_PORT) --define kb_service_dir=$(SERVICE_DIR) \
	--define kb_sphinx_port=$(SPHINX_PORT) --define kb_sphinx_host=$(SPHINX_HOST) \
	--define kb_psgi=$(SERVICE_NAME).psgi

default:

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

deploy-client: deploy-libs deploy-scripts deploy-docs

deploy-service: deploy-dir
	$(TPAGE) $(TPAGE_ARGS) service/start_service.tt > $(TARGET)/services/$(SERVICE_DIR)/start_service
	chmod +x $(TARGET)/services/$(SERVICE_DIR)/start_service
	$(TPAGE) $(TPAGE_ARGS) service/stop_service.tt > $(TARGET)/services/$(SERVICE_DIR)/stop_service
	chmod +x $(TARGET)/services/$(SERVICE_DIR)/stop_service

deploy-dir:
	if [ ! -d $(TARGET)/services/$(SERVICE_DIR) ] ; then mkdir $(TARGET)/services/$(SERVICE_DIR) ; fi
	if [ "$(SERVICE_SUBDIRS)" != "" ] ; then \
		for dir in $(SERVICE_SUBDIRS) ; do \
		    	if [ ! -d $(TARGET)/services/$(SERVICE_DIR)/$$dir ] ; then mkdir -p $(TARGET)/services/$(SERVICE_DIR)/$$dir ; fi \
		done;  \
	fi

deploy-docs: build-docs
	-mkdir -p $(TARGET)/services/$(SERVICE_NAME)/webroot/.
	cp docs/*.html $(TARGET)/services/$(SERVICE_NAME)/webroot/.

build-docs: compile-docs
	-mkdir -p docs
	pod2html --infile=lib/Bio/KBase/$(SERVICE_NAME)/Client.pm --outfile=docs/$(SERVICE_NAME).html

compile-docs: build-libs

build-libs:
	compile_typespec \
		--psgi $(SERVICE_NAME).psgi \
		--impl Bio::KBase::$(SERVICE_NAME)::$(SERVICE_NAME)Impl \
		--service Bio::KBase::$(SERVICE_NAME)::Service \
		--client Bio::KBase::$(SERVICE_NAME)::Client \
		--py biokbase/$(SERVICE_NAME)/Client \
		--js javascript/$(SERVICE_NAME)/Client \
		--scripts scripts \
		$(SERVICE_SPEC) lib

include $(TOP_DIR)/tools/Makefile.common.rules

