include Makefile.main

#
# OVERRIDEN TARGETS
# https://stackoverflow.com/questions/11958626/make-file-warning-overriding-commands-for-target
#

all: sources/controls/xx-all.adoc documents.html
	$(MAKE) -f Makefile.main $@

clean:
	$(MAKE) -f Makefile.main $@
	rm -rf controls caiq.yaml

%.adoc: sources/controls/%.adoc

#
# CUSTOM TARGETS
#

sources/controls:
	mkdir -p $@;

caiq.yaml: bundle
	bundle exec csa-ccm ccm-yaml 3.0.1 -o $@

sources/controls/%.adoc: sources/controls caiq.yaml
	scripts/build.rb
