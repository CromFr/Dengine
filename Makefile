all:
	dub build --vquiet --compiler=dmd

unittest:
	dub build --vquiet --compiler=dmd --build=unittest

coverage:
	-mkdir cov
	dub build --vquiet --compiler=dmd --build=unittest-cov
	mv *.lst .*.lst cov/

profile:
	dub build --vquiet --compiler=dmd --build=profile

doc:
	dub build --vquiet --compiler=dmd --build=docs

