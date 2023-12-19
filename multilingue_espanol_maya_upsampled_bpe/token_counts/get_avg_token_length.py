import os
import pandas as pd
from tabulate import tabulate

from icecream import ic

langs = os.listdir()
langs = [dir for dir in langs if os.path.isdir(dir)]

tokens = {lang: {} for lang in langs}

for lang in langs:
    if os.path.exists(
        f"{lang}/data.bpe.{lang}.tokens") and os.path.exists(f"{lang}/data.{lang}.tokens"):
        with open(f"{lang}/data.bpe.{lang}.tokens") as g, open(f"{lang}/data.{lang}.tokens") as f:
            tokens[lang]["bpe_tokens"] = g.readlines()
            tokens[lang]["bpe_avg_length"] = sum(len(token) for token in tokens[lang]["bpe_tokens"]) / len(tokens[lang]["bpe_tokens"])
            tokens[lang].pop("bpe_tokens")

            tokens[lang]["ssv_tokens"] = f.readlines()
            tokens[lang]["ssv_avg_length"] = sum(len(token) for token in tokens[lang]["ssv_tokens"]) / len(tokens[lang]["ssv_tokens"])
            tokens[lang].pop("ssv_tokens")

    if os.path.exists(f"{lang}/jw.tokens"):
        with open(f"{lang}/jw.tokens") as f:
            jw_tokens = set(f.readlines())
    else:
        jw_tokens = set()
    if os.path.exists(f"{lang}/vocab.tokens"):
        with open(f"{lang}/vocab.tokens") as f:
            vocab_tokens = set(f.readlines())
    else:
        vocab_tokens = set()

    intersection = jw_tokens.intersection(vocab_tokens)

    tokens[lang]["nb_jw_tokens"] = len(jw_tokens)
    tokens[lang]["nb_vocab_tokens"] = len(vocab_tokens)
    tokens[lang]["nb_intersecting_tokens"] = len(intersection)

df = pd.DataFrame(tokens)
print(tabulate(df.transpose().sort_index(), headers='keys', tablefmt='psql'))
