import json
import os
import numpy as np
import pandas as pd
from icecream import ic
from tabulate import tabulate


smoothing = .1

langs = os.listdir()
langs = [dir for dir in langs if os.path.exists(f"{dir}/data.es.jw") and os.path.exists(f"{dir}/data.es.vocab")]

with open("dialectometria_espanol_tokens_2023") as f:
    dialectometria_espanol_keys = [word.strip() for word in f.readlines()]


def normalize(u: np.array) -> np.array:
    # (xi – min(x)) / (max(x) – min(x))
    return (u - np.min(u)) / (np.max(u) - np.min(u))


def softmax(u: np.array) -> np.array:
    # u = normalize(u)
    # return (np.exp(u - np.max(u)) / np.exp(u - np.max(u)).sum())
    return u / np.sum(u)


def cosine_distance(u: np.array, v: np.array) -> float:
    assert len(u) == len(v), "Cannot compute cosine distance: dimensional" + \
                             " mismatch"

    return 1 - (np.dot(u, v) / (np.linalg.norm(u) * np.linalg.norm(v)))


def kullback_leibler(u: np.array, v: np.array) -> float:
    assert len(u) == len(v), "Cannot compute KL divergenge: dimensional" + \
                             " mismatch"

    return sum(u[idx] * np.log(u[idx] / v[idx]) for idx in range(len(u)))


def jensen_shannon(u: np.array, v: np.array) -> float:
    assert len(u) == len(v), "Cannot compute Jensen-Shannon distance: " + \
                             "dimensional mismatch"

    m = (u + v) / 2
    return np.sqrt((kullback_leibler(u, m) + kullback_leibler(v, m)) / 2)


with open("jw_tokens.unique") as f:
    jw_tokens = [token.strip() for token in f.readlines()]
    jw_tokens = [token.split() for token in jw_tokens]
    jw_tokens = {token[1]: token[0] for token in jw_tokens}

with open("vocab_tokens.unique") as f:
    vocab_tokens = [token.strip() for token in f.readlines()]
    vocab_tokens = [token.split() for token in vocab_tokens]
    vocab_tokens = {token[1]: token[0] for token in vocab_tokens}

with open("varilex.stem.json") as f:
    varilex_stem = json.loads(f.read())


jw_keys = []
vocab_keys = []

for token in jw_tokens:
    for key in varilex_stem.keys():
        if token in varilex_stem[key]:
            jw_keys.append(key)

for token in vocab_tokens:
    for key in varilex_stem.keys():
        if token in varilex_stem[key]:
            vocab_keys.append(key)

jw_keys = set(jw_keys)
vocab_keys = set(vocab_keys)
intersect_keys = jw_keys.intersection(vocab_keys)

jw_vectors = {}
vocab_vectors = {}

for key in dialectometria_espanol_keys:
    jw_vectors[key] = np.zeros(len(varilex_stem[key]))
    vocab_vectors[key] = np.zeros(len(varilex_stem[key]))
    for idx, word in enumerate(varilex_stem[key]):
        jw_freq = jw_tokens.get(word)
        vocab_freq = vocab_tokens.get(word)
        jw_vectors[key][idx] = jw_freq if jw_freq is not None else smoothing
        vocab_vectors[key][idx] = vocab_freq if vocab_freq is not None else smoothing
    jw_vectors[key] = softmax(jw_vectors[key])
    vocab_vectors[key] = softmax(vocab_vectors[key])

distances = {}

for key in jw_vectors.keys():
    u = jw_vectors[key]
    v = vocab_vectors[key]
    distances[key] = {}
    distances[key]["cosine_distance"] = cosine_distance(u, v)
    distances[key]["jensen_shannon_distance"] = jensen_shannon(u, v)

df = pd.DataFrame(distances).T

# print(tabulate(df.round(decimals=4), headers='keys', tablefmt='psql'))

avg_cosine_distance = np.average(np.array(df["cosine_distance"]))
std_cosine_distance = np.std(np.array(df["cosine_distance"]))
avg_jensen_shannon = np.average(np.array(df["jensen_shannon_distance"]))
std_jensen_shannon = np.std(np.array(df["jensen_shannon_distance"]))

print(f"Average global cosine distance: {avg_cosine_distance:.4g} ± {std_cosine_distance:.4g}")
print(f"Average global Jensen-Shannon distance: {avg_jensen_shannon:.4g} ± {std_jensen_shannon:.4g}")

for lang in "kek mam poh quc tzh".split():
    with open(f"{lang}/jw_tokens.unique") as jw, open(f"{lang}/vocab_tokens.unique") as vocab:
        jw_tokens = [token.strip() for token in jw.readlines()]
        jw_tokens = [token.split() for token in jw_tokens]
        jw_tokens = {token[1]: token[0] for token in jw_tokens}

        vocab_tokens = [token.strip() for token in vocab.readlines()]
        vocab_tokens = [token.split() for token in vocab_tokens]
        vocab_tokens = {token[1]: token[0] for token in vocab_tokens}

    jw_keys = []
    vocab_keys = []

    for token in jw_tokens:
        for key in varilex_stem.keys():
            if token in varilex_stem[key]:
                jw_keys.append(key)

    for token in vocab_tokens:
        for key in varilex_stem.keys():
            if token in varilex_stem[key]:
                vocab_keys.append(key)

    jw_keys = set(jw_keys)
    vocab_keys = set(vocab_keys)
    intersect_keys = jw_keys.intersection(vocab_keys)

    jw_vectors = {}
    vocab_vectors = {}

    for key in dialectometria_espanol_keys:
        jw_vectors[key] = np.zeros(len(varilex_stem[key]))
        vocab_vectors[key] = np.zeros(len(varilex_stem[key]))
        for idx, word in enumerate(varilex_stem[key]):
            jw_freq = jw_tokens.get(word)
            vocab_freq = vocab_tokens.get(word)
            jw_vectors[key][idx] = jw_freq if jw_freq is not None else smoothing
            vocab_vectors[key][idx] = vocab_freq if vocab_freq is not None else smoothing
        jw_vectors[key] = softmax(jw_vectors[key])
        vocab_vectors[key] = softmax(vocab_vectors[key])

    distances = {}

    for key in jw_vectors.keys():
        u = jw_vectors[key]
        v = vocab_vectors[key]
        distances[key] = {}
        distances[key]["cosine_distance"] = cosine_distance(u, v)
        distances[key]["jensen_shannon_distance"] = jensen_shannon(u, v)

    df = pd.DataFrame(distances).T

    # print(tabulate(df.round(decimals=4), headers='keys', tablefmt='psql'))

    avg_cosine_distance = np.average(np.array(df["cosine_distance"]))
    std_cosine_distance = np.std(np.array(df["cosine_distance"]))
    avg_jensen_shannon = np.average(np.array(df["jensen_shannon_distance"]))
    std_jensen_shannon = np.std(np.array(df["jensen_shannon_distance"]))

    print(f"{lang}: Average cosine distance: {avg_cosine_distance:.4g} ± {std_cosine_distance:.4g}")
    print(f"{lang}: Average Jensen-Shannon distance: {avg_jensen_shannon:.4g} ± {std_jensen_shannon:.4g}")