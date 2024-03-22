import os, json, pandas as pd

langs = os.listdir("multilingual/test/")

for lang in langs:
    os.mkdir(f"/neural/alou/corpora/{lang}")
    vocab = pd.read_csv(f"/neural/alou/corpora_mayas/{lang}/dataframes/vocabulario.csv", sep='\t')
    vocab_es = list(vocab['ejemplo es'])
    vocab_lang = list(vocab[f"ejemplo {lang}"])

    d = {
        "train": [],
        "dev": [],
        "test": [],
    }

    with open(f"/neural/alou/tan-maya/{lang}/test/data.es") as f:
        test = f.readlines()
    with open(f"/neural/alou/tan-maya/{lang}/dev/data.es") as f:
        dev = f.readlines()
    try:
        with open(f"/neural/alou/tan-maya/{lang}/train/data.es") as f:
            train = f.readlines()
    except FileNotFoundError:
        train = []

    for idx, line in enumerate(vocab_es):
        if line in test:
            d["test"].append(line)
        elif line in dev:
            d["dev"].append(line)
        else:
            d["train"].append(line)

    with open(f"/neural/alou/corpora/{lang}/test.{lang}", "a") as f, open(f"/neural/alou/corpora/{lang}/test.es", "a") as g:
        for 
