langs=$(cat langs)

cp ../cmb/train/data.bpe.es-cmb .
cp ../cmb/train/data.es .
cp ../cmb/train/data.cmb .

paste ../cmb/dev/data.bpe.es ../cmb/dev/data.bpe.cmb >> data.bpe.es-cmb

paste data.es data.cmb > data.es-cmb
paste ../cmb/dev/data.es ../cmb/dev/data.cmb >> data.es-cmb

for lang in $langs
do
    echo "$lang"
    mkdir -p $lang
    
    cat data.bpe.es-cmb | grep "#$lang#" > $lang/data.bpe.es-$lang
    cut -f1 $lang/data.bpe.es-$lang | sed 's/#.*# //' > $lang/data.bpe.es
    cut -f2 $lang/data.bpe.es-$lang > $lang/data.bpe.$lang
    rm $lang/data.bpe.es-$lang

    cat $lang/data.bpe.es | tr ' ' '\n' | sort | uniq > $lang/data.bpe.es.tokens 
    cat $lang/data.bpe.$lang | tr ' ' '\n' | sort | uniq > $lang/data.bpe.$lang.tokens 
    
    cat data.es-cmb | grep "#$lang#" > $lang/data.es-$lang
    cut -f1 $lang/data.es-$lang | sed 's/#.*# //' > $lang/data.es
    cut -f2 $lang/data.es-$lang > $lang/data.$lang
    rm $lang/data.es-$lang

    cat $lang/data.es | tr ' ' '\n' | sort | uniq > $lang/data.es.tokens 
    cat $lang/data.$lang | tr ' ' '\n' | sort | uniq > $lang/data.$lang.tokens 
done
