PACKAGE_NAME=splunk-wmbc-restricted-app
.version:
	./scripts/get-next-version.sh

build:
	./build.sh

test:
	echo "Testing splunk-wmbc-restricted-app"


ci/build: .version
	./build.sh "${WORKSPACE}/output" "${PACKAGE_NAME}" "$(shell cat .version)"

ci/publish:
	./publish.sh publish "$(shell cat .version)"

ci/tag:
	./scripts/tagger.sh tag "$(shell cat .version)"


clean:
	rm -f .version
	rm -rf target output tmpappconf