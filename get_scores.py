import os, json, pandas as pd
from icecream import ic
from tabulate import tabulate

# gather bilingual scores
langs = os.listdir()
langs = [dir for dir in langs if os.path.isdir(dir)]
langs = [dir for dir in langs if "bilingual_" in dir]

langs = [dir[-3:] for dir in langs]
bilingual_reports = {"es_maya": {}, "maya_es": {}}

for lang in langs:
    with open(f"bilingual_{lang}/model_{lang}-es/evaluation/report") as lang_es, open(f"bilingual_{lang}/model_es-{lang}/evaluation/report") as es_lang:
        bilingual_reports["es_maya"][lang] = json.loads(es_lang.read())
        bilingual_reports["maya_es"][lang] = json.loads(lang_es.read())

# gather multilingual scores
langs = os.listdir("multilingual/test")
multilingual_reports = {"es_maya": {}, "maya_es": {}}
for lang in langs:
    with open(f"multilingual/model_cmb-es/evaluation/{lang}/report") as cmb_es, open(f"multilingual/model_es-cmb/evaluation/{lang}/report") as es_cmb:
        multilingual_reports["es_maya"][lang] = json.loads(es_cmb.read())
        multilingual_reports["maya_es"][lang] = json.loads(cmb_es.read())

b_maya_es_bleu = {lang: {} for lang in bilingual_reports['maya_es'].keys()}
for lang in b_maya_es_bleu.keys():
    b_maya_es_bleu[lang] = bilingual_reports['maya_es'][lang][0]['score']

b_es_maya_bleu = {lang: {} for lang in bilingual_reports['es_maya'].keys()}
for lang in b_es_maya_bleu.keys():
    b_es_maya_bleu[lang] = bilingual_reports['es_maya'][lang][0]['score']

b_maya_es_chrf = {lang: {} for lang in bilingual_reports['maya_es'].keys()}
for lang in b_maya_es_chrf.keys():
    b_maya_es_chrf[lang] = bilingual_reports['maya_es'][lang][1]['score']

b_es_maya_chrf = {lang: {} for lang in bilingual_reports['es_maya'].keys()}
for lang in b_es_maya_chrf.keys():
    b_es_maya_chrf[lang] = bilingual_reports['es_maya'][lang][1]['score']

m_maya_es_bleu = {lang: {} for lang in multilingual_reports['maya_es'].keys()}
for lang in m_maya_es_bleu.keys():
    m_maya_es_bleu[lang] = multilingual_reports['maya_es'][lang][0]['score']

m_es_maya_bleu = {lang: {} for lang in multilingual_reports['es_maya'].keys()}
for lang in m_es_maya_bleu.keys():
    m_es_maya_bleu[lang] = multilingual_reports['es_maya'][lang][0]['score']

m_maya_es_chrf = {lang: {} for lang in multilingual_reports['maya_es'].keys()}
for lang in m_maya_es_chrf.keys():
    m_maya_es_chrf[lang] = multilingual_reports['maya_es'][lang][1]['score']

m_es_maya_chrf = {lang: {} for lang in multilingual_reports['es_maya'].keys()}
for lang in m_es_maya_chrf.keys():
    m_es_maya_chrf[lang] = multilingual_reports['es_maya'][lang][1]['score']

b_maya_es_bleu = pd.DataFrame(b_maya_es_bleu, index=['bleu']).T.sort_index()
m_maya_es_bleu = pd.DataFrame(m_maya_es_bleu, index=['bleu']).T.sort_index()

b_es_maya_bleu = pd.DataFrame(b_es_maya_bleu, index=['bleu']).T.sort_index()
m_es_maya_bleu = pd.DataFrame(m_es_maya_bleu, index=['bleu']).T.sort_index()

bleu_df = pd.concat([b_maya_es_bleu, m_maya_es_bleu, b_es_maya_bleu, m_es_maya_bleu], axis=1).sort_index().fillna("-")

b_maya_es_chrf = pd.DataFrame(b_maya_es_chrf, index=['chrf']).T.sort_index()
m_maya_es_chrf = pd.DataFrame(m_maya_es_chrf, index=['chrf']).T.sort_index()

b_es_maya_chrf = pd.DataFrame(b_es_maya_chrf, index=['chrf']).T.sort_index()
m_es_maya_chrf = pd.DataFrame(m_es_maya_chrf, index=['chrf']).T.sort_index()

chrf_df = pd.concat([b_maya_es_chrf, m_maya_es_chrf, b_es_maya_chrf, m_es_maya_chrf], axis=1).sort_index().fillna("-")

print(tabulate(chrf_df, headers='keys', tablefmt='psql'))
