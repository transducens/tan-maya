import os, json, pandas as pd
from icecream import ic
from tabulate import tabulate

# gather bilingual scores
langs = os.listdir()
langs = [dir for dir in langs if os.path.isdir(dir)]
langs = [dir for dir in langs if "bilingual_" in dir]

langs = [dir[-3:] for dir in langs]
bilingual_reports = {lang: {f"es_{lang}": {}, f"{lang}_es": {}} for lang in langs}
bilingual_reports_baseline = {lang: {f"es_{lang}": {}, f"{lang}_es": {}} for lang in langs}

for lang in langs:
    reports = {"es_lang": {}, "lang_es": {}}
    n_runs = len([dir for dir in os.listdir(f"bilingual_{lang}") if f"model_es-{lang}" in dir])
    for n in range(1, n_runs + 1):
        with open(f"bilingual_{lang}/model_{lang}-es_{n}/evaluation/report") as lang_es, open(f"bilingual_{lang}/model_es-{lang}_{n}/evaluation/report") as es_lang:
            reports["lang_es"][n] = json.loads(lang_es.read())
            reports["es_lang"][n] = json.loads(es_lang.read())

    lang_es_bleu = round(sum(reports["lang_es"][n][0]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
    es_lang_bleu = round(sum(reports["es_lang"][n][0]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
    lang_es_chrf = round(sum(reports["lang_es"][n][1]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
    es_lang_chrf = round(sum(reports["es_lang"][n][1]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)

    bilingual_reports[lang][f"{lang}_es"]["bleu"] = lang_es_bleu
    bilingual_reports[lang][f"{lang}_es"]["chrf"] = lang_es_chrf
    bilingual_reports[lang][f"es_{lang}"]["bleu"] = es_lang_bleu
    bilingual_reports[lang][f"es_{lang}"]["chrf"] = es_lang_chrf

    reports_baseline = {"es_lang": {}, "lang_es": {}}
    n_runs = len([dir for dir in os.listdir(f"bilingual_{lang}") if f"model.baseline_es-{lang}" in dir])
    if n_runs != 0:
        for n in range(1, n_runs + 1):
            with open(f"bilingual_{lang}/model.baseline_{lang}-es_{n}/evaluation/report") as lang_es, open(f"bilingual_{lang}/model.baseline_es-{lang}_{n}/evaluation/report") as es_lang:
                reports_baseline["lang_es"][n] = json.loads(lang_es.read())
                reports_baseline["es_lang"][n] = json.loads(es_lang.read())

        lang_es_bleu = round(sum(reports_baseline["lang_es"][n][0]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
        es_lang_bleu = round(sum(reports_baseline["es_lang"][n][0]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
        lang_es_chrf = round(sum(reports_baseline["lang_es"][n][1]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
        es_lang_chrf = round(sum(reports_baseline["es_lang"][n][1]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)

        bilingual_reports_baseline[lang][f"{lang}_es"]["bleu"] = lang_es_bleu
        bilingual_reports_baseline[lang][f"{lang}_es"]["chrf"] = lang_es_chrf
        bilingual_reports_baseline[lang][f"es_{lang}"]["bleu"] = es_lang_bleu
        bilingual_reports_baseline[lang][f"es_{lang}"]["chrf"] = es_lang_chrf

# gather multilingual scores
langs = os.listdir("multilingual/test")
multilingual_reports = {lang: {f"es_{lang}": {}, f"{lang}_es": {}} for lang in langs}
for lang in langs:
    reports = {"es_lang": {}, "lang_es": {}}
    n_runs = len([dir for dir in os.listdir(f"multilingual") if f"model_es-cmb" in dir])
    for n in range(1, n_runs + 1):
        with open(f"multilingual/model_cmb-es_{n}/evaluation/{lang}/report") as cmb_es, open(f"multilingual/model_es-cmb_{n}/evaluation/{lang}/report") as es_cmb:
            reports["lang_es"][n] = json.loads(cmb_es.read())
            reports["es_lang"][n] = json.loads(es_cmb.read())

    lang_es_bleu = round(sum(reports["lang_es"][n][0]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
    es_lang_bleu = round(sum(reports["es_lang"][n][0]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
    lang_es_chrf = round(sum(reports["lang_es"][n][1]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
    es_lang_chrf = round(sum(reports["es_lang"][n][1]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)

    multilingual_reports[lang][f"{lang}_es"]["bleu"] = lang_es_bleu
    multilingual_reports[lang][f"{lang}_es"]["chrf"] = lang_es_chrf
    multilingual_reports[lang][f"es_{lang}"]["bleu"] = es_lang_bleu
    multilingual_reports[lang][f"es_{lang}"]["chrf"] = es_lang_chrf

multilingual_reports_baseline = {lang: {f"es_{lang}": {}, f"{lang}_es": {}} for lang in langs}
for lang in langs:
    reports = {"es_lang": {}, "lang_es": {}}
    n_runs = len([dir for dir in os.listdir(f"multilingual") if f"model.baseline_es-cmb" in dir])
    if n_runs != 0:
        for n in range(1, n_runs + 1):
            with open(f"multilingual/model.baseline_cmb-es_{n}/evaluation/{lang}/report") as cmb_es, open(f"multilingual/model.baseline_es-cmb_{n}/evaluation/{lang}/report") as es_cmb:
                reports["lang_es"][n] = json.loads(cmb_es.read())
                reports["es_lang"][n] = json.loads(es_cmb.read())

        lang_es_bleu = round(sum(reports["lang_es"][n][0]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
        es_lang_bleu = round(sum(reports["es_lang"][n][0]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
        lang_es_chrf = round(sum(reports["lang_es"][n][1]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)
        es_lang_chrf = round(sum(reports["es_lang"][n][1]["score"] for n in range(1, n_runs + 1)) / n_runs, 1)

        multilingual_reports_baseline[lang][f"{lang}_es"]["bleu"] = lang_es_bleu
        multilingual_reports_baseline[lang][f"{lang}_es"]["chrf"] = lang_es_chrf
        multilingual_reports_baseline[lang][f"es_{lang}"]["bleu"] = es_lang_bleu
        multilingual_reports_baseline[lang][f"es_{lang}"]["chrf"] = es_lang_chrf

b_maya_es_bleu = {lang: bilingual_reports[lang][f"{lang}_es"]["bleu"] for lang in bilingual_reports.keys()}
b_maya_es_bleu = pd.DataFrame(b_maya_es_bleu, index=['bleu']).T.sort_index()

m_maya_es_bleu = {lang: multilingual_reports[lang][f"{lang}_es"]["bleu"] for lang in multilingual_reports.keys()}
m_maya_es_bleu = pd.DataFrame(m_maya_es_bleu, index=['bleu']).T.sort_index()

b_es_maya_bleu = {lang: bilingual_reports[lang][f"es_{lang}"]["bleu"] for lang in bilingual_reports.keys()}
b_es_maya_bleu = pd.DataFrame(b_es_maya_bleu, index=['bleu']).T.sort_index()

m_es_maya_bleu = {lang: multilingual_reports[lang][f"es_{lang}"]["bleu"] for lang in multilingual_reports.keys()}
m_es_maya_bleu = pd.DataFrame(m_es_maya_bleu, index=['bleu']).T.sort_index()

bleu_df = pd.concat([b_maya_es_bleu, m_maya_es_bleu, b_es_maya_bleu, m_es_maya_bleu], axis=1).sort_index().fillna("-")

b_maya_es_chrf = {lang: bilingual_reports[lang][f"{lang}_es"]["chrf"] for lang in bilingual_reports.keys()}
b_maya_es_chrf = pd.DataFrame(b_maya_es_chrf, index=['chrf']).T.sort_index()

m_maya_es_chrf = {lang: multilingual_reports[lang][f"{lang}_es"]["chrf"] for lang in multilingual_reports.keys()}
m_maya_es_chrf = pd.DataFrame(m_maya_es_chrf, index=['chrf']).T.sort_index()

b_es_maya_chrf = {lang: bilingual_reports[lang][f"es_{lang}"]["chrf"] for lang in bilingual_reports.keys()}
b_es_maya_chrf = pd.DataFrame(b_es_maya_chrf, index=['chrf']).T.sort_index()

m_es_maya_chrf = {lang: multilingual_reports[lang][f"es_{lang}"]["chrf"] for lang in multilingual_reports.keys()}
m_es_maya_chrf = pd.DataFrame(m_es_maya_chrf, index=['chrf']).T.sort_index()

chrf_df = pd.concat([b_maya_es_chrf, m_maya_es_chrf, b_es_maya_chrf, m_es_maya_chrf], axis=1).sort_index().fillna("-")

# ic(bleu_df, chrf_df)
print(tabulate(bleu_df, headers='keys', tablefmt='psql'))
print(tabulate(chrf_df, headers='keys', tablefmt='psql'))

###################
###################

b_maya_es_bleu = {lang: bilingual_reports_baseline[lang][f"{lang}_es"].get("bleu") for lang in bilingual_reports_baseline.keys()}
b_maya_es_bleu = pd.DataFrame(b_maya_es_bleu, index=['bleu']).T.sort_index()

m_maya_es_bleu = {lang: multilingual_reports_baseline[lang][f"{lang}_es"].get("bleu") for lang in multilingual_reports_baseline.keys()}
m_maya_es_bleu = pd.DataFrame(m_maya_es_bleu, index=['bleu']).T.sort_index()

b_es_maya_bleu = {lang: bilingual_reports_baseline[lang][f"es_{lang}"].get("bleu") for lang in bilingual_reports_baseline.keys()}
b_es_maya_bleu = pd.DataFrame(b_es_maya_bleu, index=['bleu']).T.sort_index()

m_es_maya_bleu = {lang: multilingual_reports_baseline[lang][f"es_{lang}"].get("bleu") for lang in multilingual_reports_baseline.keys()}
m_es_maya_bleu = pd.DataFrame(m_es_maya_bleu, index=['bleu']).T.sort_index()

bleu_df_baseline = pd.concat([b_maya_es_bleu, m_maya_es_bleu, b_es_maya_bleu, m_es_maya_bleu], axis=1).sort_index().fillna("-")

b_maya_es_chrf = {lang: bilingual_reports_baseline[lang][f"{lang}_es"].get("chrf") for lang in bilingual_reports_baseline.keys()}
b_maya_es_chrf = pd.DataFrame(b_maya_es_chrf, index=['chrf']).T.sort_index()

m_maya_es_chrf = {lang: multilingual_reports_baseline[lang][f"{lang}_es"].get("chrf") for lang in multilingual_reports_baseline.keys()}
m_maya_es_chrf = pd.DataFrame(m_maya_es_chrf, index=['chrf']).T.sort_index()

b_es_maya_chrf = {lang: bilingual_reports_baseline[lang][f"es_{lang}"].get("chrf") for lang in bilingual_reports_baseline.keys()}
b_es_maya_chrf = pd.DataFrame(b_es_maya_chrf, index=['chrf']).T.sort_index()

m_es_maya_chrf = {lang: multilingual_reports_baseline[lang][f"es_{lang}"].get("chrf") for lang in multilingual_reports_baseline.keys()}
m_es_maya_chrf = pd.DataFrame(m_es_maya_chrf, index=['chrf']).T.sort_index()

chrf_df_baseline = pd.concat([b_maya_es_chrf, m_maya_es_chrf, b_es_maya_chrf, m_es_maya_chrf], axis=1).sort_index().fillna("-")

print(tabulate(bleu_df_baseline, headers='keys', tablefmt='psql'))
print(tabulate(chrf_df_baseline, headers='keys', tablefmt='psql'))
# ic(bleu_df_baseline, chrf_df_baseline)