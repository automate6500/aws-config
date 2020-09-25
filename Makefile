TAG    = $(shell git rev-parse --short HEAD)
BRANCH = $(shell git branch --show-current)

zip:
	zip -r ../$(notdir $(CURDIR))-$(BRANCH)-$(TAG).zip . -x "*.git*" -x "*terraform*" -x "*~"
	zip -r ../$(notdir $(CURDIR)).zip . -x "*.git*" -x "*terraform*" -x "*~"

clean:
	rm -vf ../$(notdir $(CURDIR))*.zip

.PHONY: zip clean
