import os, json, pandas as pd
from icecream import ic
from tabulate import tabulate

elements = {}

for element in os.listdir():
    eval_path = f"{element}/cmb/evaluation"
    if os.path.exists(eval_path):
        elements[element] = {}
        langs = os.listdir(eval_path)
        for lang in langs:
            with open(f"{eval_path}/{lang}/report") as f:
                report = json.loads(f.read())
                elements[element][lang] = {"BLEU": report[0]["score"], "chrF2": report[1]["score"]}

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

# ic(bleu_scores)
df = pd.DataFrame.from_dict(bleu_scores)

es_maya_df = df.filter(regex="es-|multilingue_espanol_maya", axis=0)
es_maya_df = es_maya_df.dropna(how="all", axis=1).fillna("").sort_index()
# multilingue_espanol_maya = df.loc["multilingue_espanol_maya"]

maya_es_df = df.filter(regex="-es|multilingue_maya_espanol", axis=0)
maya_es_df = maya_es_df.dropna(how="all", axis=1).fillna("").sort_index()

idx = maya_es_df.index.tolist()
idx.pop(4)
maya_es_df = maya_es_df.reindex(idx + ["multilingue_maya_espanol"])


print(tabulate(es_maya_df, headers='keys', tablefmt='psql'))
print()
print(tabulate(maya_es_df, headers='keys', tablefmt='psql'))
