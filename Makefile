.PHONY: install preview validate clean

GM ?= gm
OUTPUT_DIR ?= output
BASE ?= assets/previews/reader-card-base.pcd
SOURCE ?= assets/previews/reader-card-scan.pcd
SOURCE_ALT ?= assets/previews/reader-card-overlay.pcd
METADATA ?= $(OUTPUT_DIR)/reader-card.txt
PREVIEW ?= $(OUTPUT_DIR)/reader-card.png
BASE_READ_SCALE ?= 2
SOURCE_READ_SCALE ?= 4
VALIDATION_ATTEMPTS ?= 4
OMP_NUM_THREADS ?= 1

install: preview

preview: validate
	@cd "$(OUTPUT_DIR)" && \
		umask 077 && \
		ulimit -c 0 && \
		base_dimensions="$$($(GM) identify -format '%w %h' "../$(BASE)")" && \
		set -- $$base_dimensions && \
		base_read_size="$$(($$1 * $(BASE_READ_SCALE)))x$$(($$2 * $(BASE_READ_SCALE)))" && \
		source_dimensions="$$($(GM) identify -format '%w %h' "../$(SOURCE)")" && \
		set -- $$source_dimensions && \
		source_read_size="$$(($$1 * $(SOURCE_READ_SCALE)))x$$(($$2 * $(SOURCE_READ_SCALE)))" && \
		OMP_NUM_THREADS="$(OMP_NUM_THREADS)" timeout 20s "$(GM)" convert \
			-size "$$base_read_size" \
			"../$(BASE)" \
			-size "$$source_read_size" \
			"../$(SOURCE)" \
			"PNG:reader-card.png"

validate:
	@/bin/mkdir -p "$(OUTPUT_DIR)"
	@/bin/rm -f "$(METADATA)" "$(PREVIEW)"
	@cd "$(OUTPUT_DIR)" && \
		umask 077 && \
		ulimit -c 0 && \
		base_dimensions="$$($(GM) identify -format '%w %h' "../$(BASE)")" && \
		set -- $$base_dimensions && \
		base_read_size="$$(($$1 * $(BASE_READ_SCALE)))x$$(($$2 * $(BASE_READ_SCALE)))" && \
		source_dimensions="$$($(GM) identify -format '%w %h' "../$(SOURCE)")" && \
		set -- $$source_dimensions && \
		source_read_size="$$(($$1 * $(SOURCE_READ_SCALE)))x$$(($$2 * $(SOURCE_READ_SCALE)))" && \
		validation_status=1 && \
		attempt=1 && \
		while [ "$$attempt" -le "$(VALIDATION_ATTEMPTS)" ]; do \
			validation_source="../$(SOURCE)"; \
			case "$$attempt" in 2|4) validation_source="../$(SOURCE_ALT)" ;; esac; \
			OMP_NUM_THREADS="$(OMP_NUM_THREADS)" timeout 20s "$(GM)" identify \
				-size "$$base_read_size" \
				"../$(BASE)" \
				-size "$$source_read_size" \
				"$$validation_source" > reader-card.txt; \
			validation_status=$$?; \
			[ "$$validation_status" -eq 0 ] && break; \
			attempt=$$(($$attempt + 1)); \
		done; \
		exit "$$validation_status"

clean:
	@/bin/rm -f "$(METADATA)" "$(PREVIEW)"
