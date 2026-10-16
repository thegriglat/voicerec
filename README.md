# voicerec

Наговорить текст (например, ТЗ для ИИ) в микрофон и получить его в буфере обмена.
Локально и офлайн: [whisper.cpp](https://github.com/ggml-org/whisper.cpp) + модель `large-v3-turbo`.

## Установка

Пакеты (Debian/Ubuntu):

```bash
# общее
sudo apt install build-essential cmake git ffmpeg alsa-utils xclip libnotify-bin libsdl2-dev
# NVIDIA — CUDA
sudo apt install nvidia-cuda-toolkit
# AMD/Intel — Vulkan
sudo apt install libvulkan-dev glslc mesa-vulkan-drivers vulkan-tools
```

Сборка (клонирует whisper.cpp в `src/`, скачивает модель ~1.6 ГБ в `models/`):

```bash
git clone <repo> ~/voicerec
~/voicerec/bin/vr-build
echo 'export PATH="$HOME/voicerec/bin:$PATH"' >> ~/.bashrc
```

Бэкенд выбирается автоматически: CUDA → Vulkan → CPU. Сменили железо или драйверы —
перезапустите `vr-build`.

## Команды

| Команда | Что делает |
|---|---|
| `vr` | запись до Enter/Ctrl+C → текст в stdout и буфер обмена |
| `vr toggle` | для горячей клавиши: первый вызов — старт, второй — стоп и расшифровка (уведомление) |
| `vr-stream` | живая расшифровка по ходу речи (качество ниже) |
| `vr-transcribe <файл>` | расшифровать любой аудиофайл |
| `vr-model <name>` | скачать другую модель (`small`, `medium`, `large-v3`) |

Каждая запись сохраняется в `recordings/<дата>.wav` и `.txt`.

## Настройка

`config.sh`, любую переменную можно переопределить окружением:

- `VR_LANG` — язык (`ru`, `en`, `auto`);
- `VR_PROMPT` — словарь терминов: whisper берёт из него написание (латиница, регистр);
- `VR_DEVICE` — микрофон (`arecord -L`);
- `VR_MODEL`, `VR_THREADS`.

Горячая клавиша (X11): привязать `~/voicerec/bin/vr toggle` в настройках клавиатуры окружения.
