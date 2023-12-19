import os, json
from icecream import ic
from  json.decoder import JSONDecodeError

ic.configureOutput(outputFunction=print)

langs = os.listdir("checkpoint_lang_iter")
langs_best = dict()

for lang in langs:
    best = {"bleu_scores": {}, "best_bleu": 0,
            "best_bleu_checkpoint": ""}
    checkpoints = os.listdir(f"checkpoint_lang_iter/{lang}")
    for checkpoint in checkpoints:
        try:
            with open(f"checkpoint_lang_iter/{lang}/{checkpoint}/report.dev") as f:
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

for lang in langs:
    print(f"#{lang}# {langs_best[lang]['best_bleu_checkpoint']}")
