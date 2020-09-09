TAG = $(shell git rev-parse --short HEAD)

zip:
	zip -r ../$(notdir $(CURDIR))-$(TAG).zip . -x "*.git*" -x "*terraform*" -x "*~"

clean:
	rm -vf ../$(notdir $(CURDIR))*.zip

.PHONY: zip clean
