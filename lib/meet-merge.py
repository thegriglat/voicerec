"""Склейка расшифровок двух каналов встречи в одну по времени.

stdin: строки «начало_мс<TAB>конец_мс<TAB>метка<TAB>текст» из обоих каналов.
argv: метка микрофона, метка динамиков, 1/0 — убирать эхо.

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


def words(text):
    return re.findall(r"\w+", text.lower().replace("ё", "е"))


segs = []
for line in sys.stdin:
    start, end, who, text = line.rstrip("\n").split("\t", 3)
    segs.append((int(start), int(end), who, text.strip()))
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

# подряд идущие сегменты одного говорящего — одна реплика
out = []
for start, _, who, text in segs:
    if out and out[-1][1] == who:
        out[-1][2].append(text)
    else:
        out.append([start, who, [text]])
for start, who, texts in out:
    s = start // 1000
    print(f"[{s // 3600:02d}:{s % 3600 // 60:02d}:{s % 60:02d}] {who}: {' '.join(texts)}")
