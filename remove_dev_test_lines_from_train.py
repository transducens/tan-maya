from difflib import SequenceMatcher
from tqdm import tqdm
from icecream import ic


def similar(a, b):
    return SequenceMatcher(None, a, b).ratio()


langs = ["ixl", "kek", "kjb", "mam", "poc", "poh", "quc", "ttc", "tzh"]

for lang in langs:
    with open(f"{lang}-es/cmb/train/data.cmbes") as f, \
            open(f"{lang}-es/cmb/dev/data.cmb") as g, \
            open(f"{lang}-es/cmb/test/{lang}/data.{lang}") as h:
        train = [line.strip() for line in f.readlines()]
        dev = [line.strip() for line in g.readlines()]
        test = [line.strip() for line in h.readlines()]

    ic(len(train), len(dev), len(test))
    train_filtered_dev = []
    count = 0
    for line in tqdm(train, desc=f"{lang}: iterating over dev set"):
        append = True
        for line_ in dev:
            if similar(line_, line) >= .53:
                append = False
                count += 1
                break

        if append:
            train_filtered_dev.append(line)

    ic(len(train_filtered_dev), count)
    
    train_filtered_test = []
    for line in tqdm(train_filtered_dev, desc=f"{lang}: iterating over test set"):
        append = True
        for line_ in test:
            if similar(line_, line) >= .53:
                append = False
                count += 1
                break

        if append:
            train_filtered_test.append(line)

    ic(len(train_filtered_test), count)
    with open(f"{lang}-es/cmb/train/data.cmbes.filtered", "w") as f:
        [f.write(line + '\n') for line in train_filtered_test]
