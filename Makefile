user=xnok

build:
	docker build -t ${user}/artifactory-resource -f Dockerfile .

test-check:
	bash ./test/check-test.sh ./test/request/check.json ${user}

test-in:
	bash ./test/in-test.sh ./test/request/in.json ${user}

test-out:
	bash ./test/out-test.sh ./test/request/out.json ${user}

test-out-b:
	bash ./test/out-test.sh ./test/request/out-build_publish.json ${user}

test-out-p:
	bash ./test/out-test.sh ./test/request/out-package_artifact.json ${user}