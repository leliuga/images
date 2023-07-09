ECOSYSTEM = \
  base golang node python

images: $(foreach b, $(ECOSYSTEM), $(b)/generate_images)
publish: $(foreach b, $(ECOSYSTEM), $(b)/publish_images)
ecosystem: $(foreach b, $(ECOSYSTEM), $(b)/echo_ecosystem)
clean: $(foreach b, $(ECOSYSTEM), $(b)/clean)

%/generate_images: %/clean
	@cd $(@D) && ./generate-images

%/publish_images: %/generate_images
	@find ./$(@D) -name Containerfile | awk '{ print length, $$0 }' | sort -n -s | cut -d" " -f2- | sed 's|/Containerfile|/publish_image|g' | xargs -n1 make

%/publish_image: %/Containerfile
	@./shared/images/publish.sh ./$(@D)/Containerfile

%/clean:
	@cd $(@D) ; rm -rf images/* || true

%/echo_ecosystem:
	@echo $(@D) >> ecosystem.txt