import os
import json
from icecream import ic
from json.decoder import JSONDecodeError

ic.configureOutput(outputFunction=print)
top_dir = "es-quc_kek"
langs = os.listdir("checkpoint_lang_iter")
langs_best = dict()

for lang in langs:
    best = {"bleu_scores": {}, "best_bleu": 0,
            "best_bleu_checkpoint": ""}
    checkpoints = os.listdir(f"checkpoint_lang_iter/{lang}")
    for checkpoint in checkpoints:
        try:
            with open(f"checkpoint_lang_iter/{lang}/{checkpoint}/report") as f:
                try:
                    report = json.loads(f.read())
                except JSONDecodeError:
                    report = []
        except FileNotFoundError:
            print(f"No report file found for {lang} at checkpoint '{checkpoint}'")

        if report != []:
            if report[0]['score'] > best["best_bleu"]:
                best["best_bleu_checkpoint"] = checkpoint
                best["best_bleu"] = report[0]['score']
            best["bleu_scores"][checkpoint] = report[0]['score']

    langs_best[lang] = best
    mv_report_command = f"cp checkpoint_lang_iter/{lang}/{langs_best[lang]['best_bleu_checkpoint']}/report cmb/evaluation/{lang}/report"
    os.system(mv_report_command)

ic(langs_best)
