source scripts/preprocess_corpora.sh

# compute p as shown in Conneau & Lampert
# https://proceedings.neurips.cc/paper/2019/file/c04c19c2c2474dbf5f7ac4372c5b9af1-Paper.pdf

langs="$(ls ~/corpora_mayas/) es"

function get_p(){
    declare -A p
    data=$1
    total_sents=$(wc -l < $data)
    for lang in $langs
    do
        sents=$(grep "#$lang#" $data | wc -l)
        p[$lang]=$(echo "scale=5 ; $sents/$total_sents" | bc)
    done

    echo '('
    for key in "${!p[@]}" ; do
    echo "[$key]=${p[$key]}"
    done
    echo ')'
}


function get_q() {
    alpha=$1
    data=$2
    declare -A p=$(get_p $data)
    declare -A q
    
    # Compute summation in denominator
    p_sum=0
    for p_i in ${p[@]}
    do
        p_sum=$(awk -v p_i=$p_i -v p_sum=$p_sum -v alpha=$alpha 'BEGIN{print p_sum + p_i^alpha}')
    done

    # Compute q_i for each language
    for lang in ${!p[@]}
    do
        p_i=${p[$lang]}
        q_i=$(awk -v p_i=$p_i -v alpha=$alpha -v p_sum=$p_sum 'BEGIN{print (p_i^alpha)/p_sum}')
        q[$lang]=$q_i
    done
    
    echo '('
    for key in "${!q[@]}" ; do
    echo "[$key]=${q[$key]}"
    done
    echo ')'    
}

function get_q_sentences_by_lang() {
    lang=$1
    q_i=$2
    target_corpus=$3

    # total number of sentences in target corpus
    n=$(wc -l < $target_corpus)

    # number of sentences to mine from target corpus using q
    q_n=$(echo "$q_i*$n/1" | bc)

    grep "#$lang#" $target_corpus | shuf -n $q_n -r
    
}

# increase proportion of instances of each language by making the largest fraction in q equal to 1
function normalise_q() {
    max="es"

    for lang in $langs
    do
        if (( $(echo "${q[$lang]} > ${q[$max]}" | bc -l) )) #[ ${q[$lang]} -gt ${q[$max]} ]
        then
            max=$lang
        fi
    done

    echo aquí ando
    augm_factor=$(echo "scale=5 ; ${p[$max]}/${q[$max]}" | bc)

    for key in "${!q[@]}"
    do
        q[$key]=$(echo "scale=5 ; ${q[$key]}*$augm_factor" | bc)
    done

}

sort cmb/train/data.es | uniq | sed "s/#.*#/#es#/" > cmb/train/data.es.uniq
paste -d " " cmb/train/lang_tokens cmb/train/data.cmb > cmb/train/data.cmb.tokens
cat cmb/train/data.es.uniq cmb/train/data.cmb.tokens > cmb/train/data.escmb

declare -A p=$(get_p cmb/train/data.escmb)
declare -A q=$(get_q 0.7 cmb/train/data.escmb)

normalise_q

# for i in "${!p[@]}"
# do
#   echo "key  : $i"
#   echo "value: ${p[$i]}"
# done

# for i in "${!q[@]}"
# do
#   echo "key  : $i"
#   echo "value: ${q[$i]}"
# done

echo "Antes de hacer upsampling: $(wc -l < cmb/train/data.escmb) oraciones"

for lang in $langs
do
    get_q_sentences_by_lang $lang ${q[$lang]} cmb/train/data.escmb >> cmb/train/data.escmb.augmented
done

mv cmb/train/data.escmb.augmented cmb/train/data.escmb
echo "Después de hacer upsampling: $(wc -l < cmb/train/data.escmb) oraciones"


cat cmb/train/data.escmb | grep -P "#es#" > cmb/train/data.es.upsampled
cat cmb/train/data.escmb | grep -Pv "#es#" > cmb/train/data.cmb.upsampled

rm cmb/train/data.cmb.tokens
rm cmb/train/data.escmb
rm cmb/train/data.es.uniq