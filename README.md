# voicerec

Наговорить текст (например, ТЗ для ИИ) в микрофон и получить его в буфере обмена.
Локально и офлайн: [whisper.cpp](https://github.com/ggml-org/whisper.cpp) + модель `large-v3-turbo`.
Звук никуда не уходит.

## Установка

```bash
git clone <repo> ~/voicerec
cd ~/voicerec
./setup.sh
source ~/.bashrc
```

`setup.sh` делает всё сам:

1. Ставит пакеты через `apt` (спросит пароль sudo). Под видеокарту — автоматически:
   NVIDIA → `nvidia-cuda-toolkit`, AMD/Intel → Vulkan, иначе только CPU.
2. Подтягивает сабмодуль whisper.cpp (`src/`, версия закреплена в репозитории) и собирает его под найденный бэкенд.
3. Скачивает модель `large-v3-turbo` (~1.6 ГБ) в `models/`.
4. Добавляет `bin/` в `PATH` через `~/.bashrc`.

Без sudo или с уже стоящими пакетами: `./setup.sh --no-packages`.
Сменили видеокарту или драйверы — запустите `./setup.sh` ещё раз.

Не Debian/Ubuntu — поставьте аналоги пакетов из `setup.sh` (`install_packages`)
и запустите `./setup.sh --no-packages`.

### NVIDIA

Нужен проприетарный драйвер (`nvidia-smi` должен работать) и репозиторий `non-free`
(Debian) для `nvidia-cuda-toolkit`. Проверка, что сборка взяла GPU: в выводе `vr-build`
строка `backend: CUDA`.

## Использование

| Команда | Что делает |
|---|---|
| `vr` | запись до Enter/Ctrl+C → текст в stdout и буфер обмена |
| `vr toggle` | для горячей клавиши: первый вызов — старт, второй — стоп и расшифровка (уведомление) |
| `vr-stream` | живая расшифровка по ходу речи (качество ниже) |
| `vr-transcribe <файл>` | расшифровать любой аудиофайл |
| `vr-model <name>` | скачать другую модель (`small`, `medium`, `large-v3`) |
| `vr-build` | пересобрать whisper.cpp (после смены железа/драйверов) |

Каждая запись сохраняется в `recordings/<дата>.wav` и `.txt`.

Типичный сценарий: `vr`, наговорить задачу, Enter, вставить из буфера в чат с ИИ.

### Горячая клавиша

Привязать `~/voicerec/bin/vr toggle` в настройках клавиатуры рабочего стола
(GNOME: Настройки → Клавиатура → Свои сочетания). Нажали — говорите, нажали ещё раз —
текст в буфере.

## Настройка

`config.sh`, любую переменную можно переопределить окружением (`VR_LANG=en vr`):

- `VR_LANG` — язык (`ru`, `en`, `auto`);
- `VR_PROMPT` — словарь терминов: whisper берёт из него написание (латиница, регистр).
  Впишите свои названия проектов и технологий;
- `VR_DEVICE` — микрофон, список: `arecord -L`;
- `VR_MODEL` — путь к модели, `VR_THREADS` — потоки CPU.

## Если не работает

- **Пустой текст / тишина** — не тот микрофон. `arecord -L`, выбрать устройство в `VR_DEVICE`;
  проверить запись: `arecord -d 3 /tmp/t.wav && aplay /tmp/t.wav`.
- **Медленно** — сборка ушла на CPU: смотрите строку `backend:` в выводе `vr-build`.
  Для проверки скорости возьмите модель поменьше: `vr-model small`,
  `VR_MODEL=~/voicerec/models/ggml-small.bin vr`.
- **Wayland** — буфер обмена через `xclip` работает только под X11/XWayland;
  на чистом Wayland замените `xclip -selection clipboard` на `wl-copy` в `bin/vr`.

## Обновить whisper.cpp

`src/` — git submodule, версия закреплена коммитом этого репозитория:

```bash
git submodule update --remote src
vr-build
git commit -am "Bump whisper.cpp"
```
