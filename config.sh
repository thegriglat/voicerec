# Настройки voicerec. Подключается всеми скриптами из bin/.
VOICEREC_HOME="${VOICEREC_HOME:-$HOME/voicerec}"

# Модель: large-v3-turbo-q5_0 — квантованная turbo, ~550 МБ вместо 1.6 ГБ,
# по качеству для русского почти без потерь. Полная: large-v3-turbo.
# Другие: small, medium, large-v3 (скачать: vr-model <name>).
VR_MODEL_NAME="${VR_MODEL_NAME:-large-v3-turbo-q5_0}"
VR_MODEL="${VR_MODEL:-$VOICEREC_HOME/models/ggml-$VR_MODEL_NAME.bin}"
# VAD (Silero): вырезает тишину до распознавания. Без него whisper на паузах
# выдумывает фразы из субтитров («Продолжение следует...»). 0 — выключить.
VR_VAD="${VR_VAD:-1}"
VR_VAD_MODEL_NAME="${VR_VAD_MODEL_NAME:-silero-v6.2.0}"
VR_VAD_MODEL="$VOICEREC_HOME/models/ggml-$VR_VAD_MODEL_NAME.bin"
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
