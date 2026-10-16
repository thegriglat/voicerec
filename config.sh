# Настройки voicerec. Подключается всеми скриптами из bin/.
VOICEREC_HOME="${VOICEREC_HOME:-$HOME/voicerec}"

# Модель: large-v3-turbo — лучший баланс качества и скорости для русского.
# Другие: ./bin/vr-model <name> (small, medium, large-v3 ...)
VR_MODEL="${VR_MODEL:-$VOICEREC_HOME/models/ggml-large-v3-turbo.bin}"
VR_LANG="${VR_LANG:-ru}"
VR_THREADS="${VR_THREADS:-8}"

# Подсказка модели: словарь терминов, которые она иначе исказит.
# Whisper подхватывает написание из подсказки (латиница, регистр).
VR_PROMPT="${VR_PROMPT:-Техническое задание для разработчика. NestJS, Prisma, Quasar, Vue, BullMQ, Redis, PostgreSQL, Docker, API, DTO, endpoint, backend, frontend.}"

# Микрофон: default — системный по умолчанию (PipeWire/PulseAudio).
# Список устройств: arecord -L
VR_DEVICE="${VR_DEVICE:-default}"

VR_BIN="$VOICEREC_HOME/src/build/bin"
VR_RECORDINGS="$VOICEREC_HOME/recordings"
