import Stemmer

stemmer = Stemmer.Stemmer('spanish')
with open("jw_tokens.es") as f, open("vocab_tokens.es") as g:
    jw_tokens = f.readlines()
    jw_tokens = [word.strip() for word in jw_tokens]
    vocab_tokens = g.readlines()
    vocab_tokens = [word.strip() for word in vocab_tokens]

with open("jw_tokens.es", "w") as f, open("vocab_tokens.es", "w") as g:
    for word in stemmer.stemWords(jw_tokens):
        f.write(word + "\n")

    for word in stemmer.stemWords(vocab_tokens):
        g.write(word + "\n")

langs = "kek mam poh quc tzh".split()

for lang in langs:
    with open(f"{lang}/jw_tokens.es") as f, open(f"{lang}/vocab_tokens.es") as g:
        jw_tokens = f.readlines()
        jw_tokens = [word.strip() for word in jw_tokens]
        vocab_tokens = g.readlines()
        vocab_tokens = [word.strip() for word in vocab_tokens]

    with open(f"{lang}/jw_tokens.es", "w") as f, open(f"{lang}/vocab_tokens.es", "w") as g:
        for word in stemmer.stemWords(jw_tokens):
            f.write(word + "\n")

        for word in stemmer.stemWords(vocab_tokens):
            g.write(word + "\n")
