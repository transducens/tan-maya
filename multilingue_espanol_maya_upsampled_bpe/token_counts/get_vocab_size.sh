home=/neural/alou
langs=$(ls $home/corpora_mayas/)

for lang in $langs
do
    echo $lang
    mkdir -p $lang
    if [ -d $home/corpora_mayas/$lang/jw ]
    then
        cat $home/corpora_mayas/$lang/jw/data.$lang | \
            tr ' ' '\n' | \
            sort | \
            uniq > $lang/jw.tokens
    fi

    if [ -d $home/corpora_mayas/$lang/dataframes ]
    then
        cat $home/corpora_mayas/$lang/dataframes/vocabulario.csv | \
        rev | \
        cut -f2 | \
        rev | \
        tr ' ' '\n' | \
        sort | \
        uniq > $lang/vocab.tokens
    fi

    nb_jw=$(wc -l < $lang/jw.tokens)
    nb_vocab=$(wc -l < $lang/vocab.tokens)
    intersect=$(grep -Fxf $lang/jw.tokens $lang/vocab.tokens | wc -l)
    echo "## $lang ##"
    echo "nb tokens jw: $nb_jw"
    echo "nb tokens vocab: $nb_vocab"
    echo "nb intersecting tokens: $intersect"
done
    
