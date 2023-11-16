IMAGE_REPO = seanlim0101/utilityapp
DEV_IMAGE_TAG = dev

build:
	docker build . -t ${IMAGE_REPO}:${DEV_IMAGE_TAG}

tag:
	docker tag ${IMAGE_REPO}:${DEV_IMAGE_TAG} ${IMAGE_REPO}:$(TAG)
	docker push ${IMAGE_REPO}:$(TAG)

test:
	echo 'no test defined'

scan:
	docker scout cves local://${IMAGE_REPO}:${DEV_IMAGE_TAG}

scan-fix:
	docker scout recommendations local://${IMAGE_REPO}:${DEV_IMAGE_TAG}

quickview:
	docker scout quickview local://${IMAGE_REPO}:${DEV_IMAGE_TAG}