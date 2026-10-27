"""Расшифровка встречи по фразам: одна фраза — одна строка с временем.

stdin: сегменты whisper «начало_мс<TAB>конец_мс<TAB>текст».

Сегмент whisper — не фраза: он то обрывает предложение посередине, то
вмещает несколько. Поэтому текст режется по концу предложения (.?!…),
а при долгой паузе фраза закрывается и без точки.

Галлюцинации: на шуме и паузах whisper выдумывает фразы из обучающих субтитров
(«Продолжение следует», «Субтитры сделал…»). Такие сегменты выбрасываем.
"""
import re
import sys

PAUSE_MS = 2000  # пауза длиннее закрывает фразу, даже без точки
SENTENCE_END = re.compile(r"(?<=[.?!…])\s+")

# Ищутся в тексте, приведённом к нижнему регистру, «ё» → «е»
HALLUCINATION_SUBSTR = [
    "dimatorzok",
    "субтитры сделал",
    "субтитры создавал",
    "субтитры подготовил",
    "субтитры делал",
    "редактор субтитров",
    "корректор субтитров",
    "субтитры by",
    "amara.org",
    "подписывайтесь на канал",
    "ставьте лайк",
    "спасибо за просмотр",
    "благодарю за просмотр",
]
# Сегмент целиком из такой фразы; «[музыка]», «(смех)» и пустые сюда же
HALLUCINATION_FULL = re.compile(
    r"(продолжение следует|до новых встреч|до встречи в следующем видео|"
    r"субтитры|музыка|аплодисменты|смех|blank_audio)?"
)


def words(text):
    return re.findall(r"\w+", text.lower().replace("ё", "е"))


def is_hallucination(text):
    norm = " ".join(words(text))
    return any(s in norm for s in HALLUCINATION_SUBSTR) or HALLUCINATION_FULL.fullmatch(norm)


segs = []
for line in sys.stdin:
    start, end, text = line.rstrip("\n").split("\t", 2)
    if not is_hallucination(text):
        segs.append((int(start), int(end), text.strip()))
segs.sort(key=lambda s: s[0])


def stamp(ms):
    s = ms // 1000
    return f"[{s // 3600:02d}:{s % 3600 // 60:02d}:{s % 60:02d}]"


# Начало предложения внутри сегмента — по доле символов до него: whisper
# не даёт времени отдельных слов в CSV, а речь идёт примерно равномерно.
phrase, phrase_start, prev_end = [], 0, None
for start, end, text in segs:
    if phrase and start - prev_end > PAUSE_MS:
        print(stamp(phrase_start), " ".join(phrase))
        phrase = []
    pos = 0
    for part in SENTENCE_END.split(text):
        if not phrase:
            phrase_start = start + (end - start) * pos // max(len(text), 1)
        phrase.append(part)
        pos += len(part) + 1
        if re.search(r"[.?!…]$", part):
            print(stamp(phrase_start), " ".join(phrase))
            phrase = []
    prev_end = end
if phrase:
    print(stamp(phrase_start), " ".join(phrase))
