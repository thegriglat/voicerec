# Настройки voicerec. Подключается всеми скриптами из bin/.
VOICEREC_HOME="${VOICEREC_HOME:-$HOME/voicerec}"

# Модель: large-v3 — полная, ~3 ГБ, лучшее качество для русского.
# Быстрее и легче: large-v3-turbo-q5_0 (~550 МБ), large-v3-turbo.
# Другие: small, medium (скачать: vr-model <name>).
VR_MODEL_NAME="${VR_MODEL_NAME:-large-v3}"
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

# Запись встреч (vr meet): микрофон и звук компьютера — в разные каналы.
# Имена источников PulseAudio/PipeWire, список: pactl list short sources
# (звук компьютера — источник *.monitor нужного выхода).
VR_MEET_MIC="${VR_MEET_MIC:-default}"
VR_MEET_SPEAKERS="${VR_MEET_SPEAKERS:-@DEFAULT_MONITOR@}"
# Метки реплик в расшифровке
VR_MEET_ME="${VR_MEET_ME:-Я}"
VR_MEET_THEM="${VR_MEET_THEM:-Собеседники}"
# Убирать эхо: без наушников микрофон слышит собеседников, и их реплики
# дублируются с меткой «Я». Дубль узнаётся по совпадению времени и текста. 0 — выключить.
VR_MEET_DEDUP="${VR_MEET_DEDUP:-1}"
