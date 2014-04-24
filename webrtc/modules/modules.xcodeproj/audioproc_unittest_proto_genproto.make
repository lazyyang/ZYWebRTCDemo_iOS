all: \
    $(BUILT_PRODUCTS_DIR)/pyproto/webrtc/audio_processing/unittest_pb2.py

$(BUILT_PRODUCTS_DIR)/pyproto/webrtc/audio_processing/unittest_pb2.py \
    $(SHARED_INTERMEDIATE_DIR)/protoc_out/webrtc/audio_processing/unittest.pb.cc \
    $(SHARED_INTERMEDIATE_DIR)/protoc_out/webrtc/audio_processing/unittest.pb.h \
    : \
    audio_processing/test/unittest.proto \
    ../../tools/protoc_wrapper/protoc_wrapper.py \
    $(BUILT_PRODUCTS_DIR)/protoc
	@mkdir -p "$(BUILT_PRODUCTS_DIR)/pyproto/webrtc/audio_processing" "$(SHARED_INTERMEDIATE_DIR)/protoc_out/webrtc/audio_processing"
	@echo note: "Generating C++ and Python code from audio_processing/test/unittest.proto"
	python ../../tools/protoc_wrapper/protoc_wrapper.py --include "" --protobuf "$(SHARED_INTERMEDIATE_DIR)/protoc_out/webrtc/audio_processing/unittest.pb.h" --proto-in-dir audio_processing/test --proto-in-file "unittest.proto" "--use-system-protobuf=0" -- "$(BUILT_PRODUCTS_DIR)/protoc" --cpp_out "$(SHARED_INTERMEDIATE_DIR)/protoc_out/webrtc/audio_processing" --python_out "$(BUILT_PRODUCTS_DIR)/pyproto/webrtc/audio_processing"
