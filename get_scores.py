import os, json, pandas as pd
from icecream import ic
from tabulate import tabulate

elements = {}

for element in os.listdir():
    eval_path = f"{element}/cmb/evaluation"
    if os.path.exists(eval_path) or "multilingue_espanol_maya_upsampled" in eval_path:
        elements[element] = {}
        langs = os.listdir(eval_path)
        for lang in langs:
            try:
             with open(f"{eval_path}/{lang}/report") as f:
                 report = json.loads(f.read())
                 elements[element][lang] = {"BLEU": report[0]["score"], "chrF2": report[1]["score"]}
            except Exception:
                pass

bleu_scores = {}
langs = os.listdir("/neural/alou/corpora_mayas")

for lang in langs:
    bleu_scores[lang] = {}
    for element in elements.keys():
        try:
            bleu = elements[element][lang]["BLEU"]
        except KeyError:
            bleu = None
        if bleu is not None:
            bleu_scores[lang][element] = bleu

df = pd.DataFrame.from_dict(bleu_scores)

es_maya_df = df.filter(regex="es-|multilingue_espanol_maya", axis=0)
es_maya_df = es_maya_df.dropna(how="all", axis=1).fillna("").sort_index()
es_maya_df = es_maya_df.drop("multilingue_espanol_maya")

maya_es_df = df.filter(regex="-es|multilingue_maya_espanol", axis=0)
maya_es_df = maya_es_df.dropna(how="all", axis=1).fillna("").sort_index()

### BEGIN CHAPUZ

multilingue_maya_espanol = {
    "acr": 1.90,
    "agu": 1.46,
    "cac": 4.87,
    "itz": 0.75,
    "ixl": 6.76,
    "kek": 8.62,
    "kjb": 6.73,
    "mam": 4.87,
    "poc": 9.53,
    "poh": 4.59,
    "quc": 5.46,
    "qum": 1.71,
    "ttc": 11.01,
    "tzh": 60.13,
    "tzj": 5.10
}

multilingue_maya_espanol = pd.DataFrame(multilingue_maya_espanol, index=["multilingue_maya_espanol"])
# ic(multilingue_maya_espanol)
maya_es_df = pd.concat([maya_es_df, multilingue_maya_espanol]).fillna("")
### END CHAPUZ

print(tabulate(es_maya_df, headers='keys', tablefmt='psql'))
print()
print(tabulate(maya_es_df, headers='keys', tablefmt='psql'))
