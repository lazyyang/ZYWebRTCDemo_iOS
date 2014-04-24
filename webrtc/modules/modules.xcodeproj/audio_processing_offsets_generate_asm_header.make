all: \
    $(SHARED_INTERMEDIATE_DIR)/audio_processing/asm_offsets/aecm_core_neon_offsets.h \
    $(SHARED_INTERMEDIATE_DIR)/audio_processing/asm_offsets/nsx_core_neon_offsets.h

$(SHARED_INTERMEDIATE_DIR)/audio_processing/asm_offsets/aecm_core_neon_offsets.h \
    : \
    audio_processing/aecm/aecm_core_neon_offsets.c \
    ../build/generate_asm_header.py
	@mkdir -p "$(SHARED_INTERMEDIATE_DIR)/audio_processing/asm_offsets"
	@echo note: "Generating assembly header files"
	python ../../webrtc/build/generate_asm_header.py "--compiler=clang" "--options=-arch armv7 -I../../webrtc/.. -isysroot $(SDKROOT) -S" "--pattern=_offset_" "--dir=$(SHARED_INTERMEDIATE_DIR)/audio_processing/asm_offsets" "audio_processing/aecm/aecm_core_neon_offsets.c"

$(SHARED_INTERMEDIATE_DIR)/audio_processing/asm_offsets/nsx_core_neon_offsets.h \
    : \
    audio_processing/ns/nsx_core_neon_offsets.c \
    ../build/generate_asm_header.py
	@mkdir -p "$(SHARED_INTERMEDIATE_DIR)/audio_processing/asm_offsets"
	@echo note: "Generating assembly header files"
	python ../../webrtc/build/generate_asm_header.py "--compiler=clang" "--options=-arch armv7 -I../../webrtc/.. -isysroot $(SDKROOT) -S" "--pattern=_offset_" "--dir=$(SHARED_INTERMEDIATE_DIR)/audio_processing/asm_offsets" "audio_processing/ns/nsx_core_neon_offsets.c"
