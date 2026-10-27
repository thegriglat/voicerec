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


VR_BIN="$VOICEREC_HOME/src/build/bin"
VR_RECORDINGS="$VOICEREC_HOME/recordings"

# Устройства — источники PulseAudio/PipeWire. Выбираются при запуске vr из терминала
# или командой vr devices и запоминаются в $VR_DEVICES_FILE.
# Вручную: имена из pactl list short sources (звук компьютера — *.monitor нужного выхода).
VR_DEVICES_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/voicerec/devices"
[ -f "$VR_DEVICES_FILE" ] && source "$VR_DEVICES_FILE"
# Микрофон: default — системный по умолчанию
VR_MIC="${VR_MIC:-${VR_MIC_SAVED:-default}}"
# Звук компьютера для vr meet: монитор выхода по умолчанию
VR_SPEAKERS="${VR_SPEAKERS:-${VR_SPEAKERS_SAVED:-@DEFAULT_MONITOR@}}"
