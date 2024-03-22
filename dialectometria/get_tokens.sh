home=/neural/alou
langs=$(ls $home/corpora_mayas)

exp="[a-záéíóúüñ]+"
for lang in $langs
do
    echo "## $lang ##"
    mkdir -p $lang
    cp stem.py $lang/stem.py
    if [ -d $home/corpora_mayas/$lang/dataframes ]
    then
        cut -f5 $home/corpora_mayas/$lang/dataframes/vocabulario.csv >> data.es.vocab
        cut -f5 $home/corpora_mayas/$lang/dataframes/vocabulario.csv > $lang/data.es.vocab
    	cat $lang/data.es.vocab | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | grep -oP "$exp" | sort > $lang/vocab_tokens.es
    fi

    if [ -d $home/corpora_mayas/$lang/jw ]
    then
    	cat $home/corpora_mayas/$lang/jw/data.es >> data.es.jw
    	cat $home/corpora_mayas/$lang/jw/data.es > $lang/data.es.jw
        cat $lang/data.es.jw | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | grep -oP "$exp" | sort > $lang/jw_tokens.es
    fi
done

cat data.es.vocab | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | grep -oP "$exp" | sort > vocab_tokens.es
cat data.es.jw | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | grep -oP "$exp" | sort > jw_tokens.es
#python stem.py
cat jw_tokens.es | uniq -c > jw_tokens.unique
cat vocab_tokens.es | uniq -c >vocab_tokens.unique

cat jw_tokens.es | uniq > jw_tokens.unique.nofreq
cat vocab_tokens.es | uniq > vocab_tokens.unique.nofreq

grep -Fxf jw_tokens.unique.nofreq vocab_tokens.unique.nofreq | sort | uniq > intersecting_tokens

rm data.es*
rm jw_tokens.es
rm vocab_tokens.es
rm *nofreq

for lang in $langs
do
    cat $lang/jw_tokens.es | uniq -c > $lang/jw_tokens.unique
    cat $lang/vocab_tokens.es | uniq -c > $lang/vocab_tokens.unique
done
