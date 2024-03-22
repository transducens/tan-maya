import json
import os
import numpy as np
import pandas as pd
from icecream import ic
from tabulate import tabulate
from tqdm import tqdm

CONCEPTS = [
    'STAPLER',
    'SIDEWALK',
    'BEDSPREAD',
    'FLIGHT ATTENDANT',
    'POSTER',
    'PENCIL SHARPENER',
    'BRA',
    'SWIMMING POOL',
    'POPCORN',
    'SANDALS',
    'ALUMINUM PAPER',
    'GLASSES',
    'STORE WINDOW',
    'COAT HANGER',
    'ELEVATOR',
    'HEADPHONES',
    'CAR',
    'BUS',
    'JEANS',
    'BACKPACK',
    'BOAT',
    'FENDER',
    'SANDWICH',
    'SUITCASE',
    'BOXERS',
    'LIGHTER',
    'BACKHOE',
    'POT/PAN',
    'SOCKS',
    'MATCHSTICK',
    'RECLINING CHAIR',
    'LIVING ROOM',
    'COMPUTER',
    'HEADLIGHT',
    'SKIRT',
    'BLACKBOARD',
    'DISH DRAINER',
    'PONCHO',
    'STREET LIGHT',
    'DISHWASHER',
    'REFRIGERATOR',
    'TOILET PAPER',
    'RECORD PLAYER',
    'SLICE OF CHEESE ',
    'DEMIJOHN',
    'WASHER',
    'PLASTER',
    'ATTIC',
    'WARDROBE',
    'BRACERS',
    'RING',
    'TAPE RECORDER',
    'BLINDMAN’S BUFF ',
    'MERRY-GO-ROUND',
    'LOUDSPEAKER',
    'FLOWER POT',
    'FANS',
    'WAITER',
    'SCHOOL',
    'AMUSEMENT',
    'STAY',
    'MISS',
    'CHEEK',
    'MONKEY',
    'MOSQUITO',
    'CHANCE',
    'SPONSOR',
    'PARCEL',
    'BANANA',
    'DUST',
    'BAR',
    'EARTHQUAKE',
    'SHOOTING',
    'GLANCE',
    'BEAUTIFUL',
    'COLD',
    'CELLOPHANE TAPE',
    'CRANE',
    'FRUIT CUP',
    'GAS STATION',
    'INTERVIEW',
    'OBSTINATE',
    'PEANUT',
    'SCRATCH',
    'SWEETENER',
    'THAW',
    'MISS',
    'PARK',
]

smoothing = 0.01

langs = os.listdir()
langs = [dir for dir in langs if os.path.exists(f"{dir}/data.es.jw") and os.path.exists(f"{dir}/data.es.vocab")]

with open("dialectometria_espanol_tokens_2023") as f:
    dialectometria_espanol_keys = [word.strip() for word in f.readlines()]


def normalize(u: np.array) -> np.array:
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


with open("varilex.json") as f:
    varilex = json.loads(f.read())

jw_distances = {}
vectors = {}
words = {}
n_concepts = {}

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
        for key in [key for key in CONCEPTS if key in varilex.keys()]:
            if token in varilex[key]:
                jw_keys.append(key)

    for token in vocab_tokens:
        for key in [key for key in CONCEPTS if key in varilex.keys()]:
            if token in varilex[key]:
                vocab_keys.append(key)

    jw_keys = set(jw_keys)
    vocab_keys = set(vocab_keys)
    intersect_keys = jw_keys.intersection(vocab_keys)
    n_concepts[lang] = len(intersect_keys)

    jw_vectors = {}
    vocab_vectors = {}

    jw_words = {}
    vocab_words = {}

    for key in [key for key in CONCEPTS if key in varilex.keys()]:
        
        jw_vectors[key] = np.zeros(len(varilex[key]))
        vocab_vectors[key] = np.zeros(len(varilex[key]))

        jw_words[key] = {}
        vocab_words[key] = {}
        
        for idx, word in enumerate(varilex[key]):
            jw_freq = jw_tokens.get(word)
            vocab_freq = vocab_tokens.get(word)
            jw_vectors[key][idx] = jw_freq if jw_freq is not None else smoothing
            vocab_vectors[key][idx] = vocab_freq if vocab_freq is not None else smoothing

            if jw_tokens.get(word) is not None:
                jw_words[key][idx] = word
            if vocab_tokens.get(word) is not None:
                vocab_words[key][idx] = word

        jw_vectors[key] = np.around(normalize(jw_vectors[key]), decimals=2)
        vocab_vectors[key] = np.around(normalize(vocab_vectors[key]), decimals=2)

    # ic(jw_words, vocab_words)
    # exit(0)

    distances = {}
    vectors[lang] = {"jw": {key: jw_vectors[key].tolist() for key in jw_vectors.keys()}, "vocab": {key: vocab_vectors[key].tolist() for key in vocab_vectors.keys()}}
    words[lang] = {"jw": {key: jw_words[key] for key in jw_words.keys()}, "vocab": {key: vocab_words[key] for key in vocab_words.keys()}}

    for key in jw_vectors.keys():
        u = jw_vectors[key]
        v = vocab_vectors[key]
        distances[key] = {}
        distances[key]["cosine_distance"] = cosine_distance(u, v)
        # distances[key]["jensen_shannon_distance"] = jensen_shannon(u, v)
    distances["avg"] = sum(distances[key]["cosine_distance"] for key in distances.keys())/len(distances)

    jw_distances[lang] = distances["avg"]

vectors_words = {}

for lang in words.keys():
    vectors_words[lang] = {}
    for corpus in words[lang].keys():
        vectors_words[lang][corpus] = {}
        for concept in words[lang][corpus].keys():
            vectors_words[lang][corpus][concept] = {}
            for idx in words[lang][corpus][concept].keys():
                vectors_words[lang][corpus][concept][idx] = words[lang][corpus][concept][idx], vectors[lang][corpus][concept][idx]

with open("vectors.jw", "w") as f, open("words.jw", "w") as g, open("vectors_words.jw", "w") as h:
    f.write(json.dumps(vectors))
    g.write(json.dumps(words))
    h.write(json.dumps(vectors_words))

# exit(0)

jw_df = pd.DataFrame(jw_distances, columns="kek mam poh quc tzh".split(), index=["jw"]).T
langs = "acr agu cac itz ixl kek kjb mam poc poh quc qum ttc tzh tzj".split()

langs_array = np.ones([len(langs), len(langs)])

for m, m_lang in tqdm(enumerate(langs), desc="iterating over langs"):
    for n, n_lang in enumerate(langs):
        if not np.isnan(langs_array[m, n]):
            with open(f"{m_lang}/vocab_tokens.unique") as f, open(f"{n_lang}/vocab_tokens.unique") as g:
                m_tokens = [token.strip() for token in f.readlines()]
                m_tokens = [token.split() for token in m_tokens]
                m_tokens = {token[1]: token[0] for token in m_tokens}

                n_tokens = [token.strip() for token in g.readlines()]
                n_tokens = [token.split() for token in n_tokens]
                n_tokens = {token[1]: token[0] for token in n_tokens}
                
            m_keys = []
            n_keys = []
            # ic(m_lang)
            for token in m_tokens:
                for key in [key for key in CONCEPTS if key in varilex.keys()]:
                    if token in varilex[key]:
                        m_keys.append(key)
                        # ic(token, key)
            # print("++++++++++")

            for token in n_tokens:
                for key in [key for key in CONCEPTS if key in varilex.keys()]:
                    if token in varilex[key]:
                        n_keys.append(key)

            m_keys = set(m_keys)
            n_keys = set(n_keys)
            intersect_keys = m_keys.intersection(n_keys)

            # n_concepts[m_lang] = len(m_keys)

            m_vectors = {}
            n_vectors = {}

            for key in [key for key in CONCEPTS if key in varilex.keys()]:
                m_vectors[key] = np.zeros(len(varilex[key]))
                n_vectors[key] = np.zeros(len(varilex[key]))
                for idx, word in enumerate(varilex[key]):
                    m_freq = m_tokens.get(word)
                    n_freq = n_tokens.get(word)
                    m_vectors[key][idx] = m_freq if m_freq is not None else smoothing
                    n_vectors[key][idx] = n_freq if n_freq is not None else smoothing
                m_vectors[key] = normalize(m_vectors[key])
                n_vectors[key] = normalize(n_vectors[key])

            distances = {}

            for key in m_vectors.keys():
                u = m_vectors[key]
                v = n_vectors[key]
                distances[key] = {}
                distances[key]["cosine_distance"] = cosine_distance(u, v)

            distances["avg"] = sum(distances[key]["cosine_distance"] for key in distances.keys())/len(distances)
            langs_array[m, n] = distances["avg"]
            langs_array[n, m] = int(len(intersect_keys)) if m_lang != n_lang else np.nan

n = pd.DataFrame(n_concepts, columns=langs, index=["n_jw"]).T

df = pd.DataFrame(langs_array, index=langs, columns=langs)
df = pd.concat([n, jw_df, df], axis=1).fillna("-").sort_index()
df = df.style.format(decimal='.', thousands=' ', precision=3)
print(df.to_latex())