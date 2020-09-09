zip:
	zip -r ../$(notdir $(CURDIR)).zip . -x "*.git*" -x "*terraform*" -x "*~"
