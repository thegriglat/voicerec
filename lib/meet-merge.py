"""Склейка расшифровок двух каналов встречи в одну по времени.

stdin: строки «начало_мс<TAB>конец_мс<TAB>метка<TAB>текст» из обоих каналов.
argv: метка микрофона, метка динамиков, 1/0 — убирать эхо.

Галлюцинации: на шуме и паузах whisper выдумывает фразы из обучающих субтитров
(«Продолжение следует», «Субтитры сделал…»). Такие сегменты выбрасываем.

Эхо: без наушников микрофон слышит динамики, и реплика собеседника
распознаётся ещё раз в канале микрофона. Такая реплика совпадает с репликой
собеседника по времени и почти дословно по тексту — её выбрасываем.
Свои слова в споре обычно другие, поэтому по тексту они не совпадают.
"""
import re
import sys

me, them, dedup = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
TOLERANCE_MS = 1500  # эхо распознаётся с небольшим сдвигом границ сегментов
MIN_SHARED = 0.6  # доля своих букв, найденных у собеседника, чтобы счесть эхом
MERGE_GAP_MS = 2000  # сегменты с паузой больше — разные реплики
MAX_LINE_MS = 60000  # длиннее реплику не растим, иначе её не прочитать

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
    start, end, who, text = line.rstrip("\n").split("\t", 3)
    segs.append((int(start), int(end), who, text.strip()))
segs = [s for s in segs if not is_hallucination(s[3])]
segs.sort(key=lambda s: s[0])


# Слово ищется в тексте собеседника без пробелов: whisper пишет одно и то же
# то слитно, то раздельно («суперклассно» / «супер классно»). Доля считается
# по буквам, чтобы короткие «да», «не», «и» почти ничего не решали.
def is_echo(seg):
    start, end, _, text = seg
    mine = words(text)
    if not mine:
        return False
    heard = "".join(
        "".join(words(t))
        for s, e, who, t in segs
        if who == them and s < end + TOLERANCE_MS and e > start - TOLERANCE_MS
    )
    shared = sum(len(w) for w in mine if w in heard)
    return shared / sum(len(w) for w in mine) >= MIN_SHARED


if dedup:
    segs = [s for s in segs if s[2] != me or not is_echo(s)]

# Подряд идущие сегменты одного говорящего — одна реплика, если между ними
# короткая пауза. Реплика собеседника между ними разрывает склейку, поэтому
# порядок ответов сохраняется.
out = []
for start, end, who, text in segs:
    prev = out[-1] if out else None
    if prev and prev[2] == who and start - prev[1] < MERGE_GAP_MS and end - prev[0] <= MAX_LINE_MS:
        prev[1] = max(prev[1], end)
        prev[3].append(text)
    else:
        out.append([start, end, who, [text]])
for start, _, who, texts in out:
    s = start // 1000
    print(f"[{s // 3600:02d}:{s % 3600 // 60:02d}:{s % 60:02d}] {who}: {' '.join(texts)}")
