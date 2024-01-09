# compute p as shown in Conneau & Lampert
# https://proceedings.neurips.cc/paper/2019/file/c04c19c2c2474dbf5f7ac4372c5b9af1-Paper.pdf

get_p(){
    # data: the train data file containing the language tokens
    # returns a hashmap
    declare -A p_
    data=$1

    # get lang id tokens
    langs=$(cat $data | grep -oP "#[a-z]+#" | sort | uniq | sed "s/#//g")

    total_sents=$(wc -l < $data)
    for lang in $langs
    do
        sents=$(grep "#$lang#" $data | wc -l)
        p_[$lang]=$(echo "scale=5 ; $sents/$total_sents" | bc)
    done

    echo '('
    for key in "${!p_[@]}" ; do
    echo "[$key]=${p_[$key]}"
    done
    echo ')'
}

get_q() {
    echo "##################"   > log
    echo $(date) >> log
    # alpha: the smoothing factor
    # data the train data file to be upsampled
    alpha=$1
    data=$2

    declare -A p_ref=$(get_p $data)
    langs=${!p_ref[@]}

    declare -A q_ref

    # Compute summation in denominator
    p_sum=0
    for p_i in ${p_ref[@]}
    do
        p_sum=$(awk -v p_i=$p_i -v p_sum=$p_sum -v alpha=$alpha 'BEGIN{print p_sum + p_i^alpha}')
    done

    # Compute q_i for each language
    for lang in ${!p_ref[@]}
    do
        p_i=${p_ref[$lang]}
        q_i=$(awk -v p_i=$p_i -v alpha=$alpha -v p_sum=$p_sum 'BEGIN{print (p_i^alpha)/p_sum}')
        q_ref[$lang]=$q_i
    done

    # retrieving the first lang id token
    max=$(echo ${!p_ref[@]} | cut -d " " -f1)

    # find the language with the greatest q value
    for lang in $langs
    do
        if (( $(echo "${q_ref[$lang]} > ${q_ref[$max]}" | bc -l) )) #[ ${q[$lang]} -gt ${q[$max]} ]
        then
            max=$lang
        fi
    done

    # compute the augmentation factor as a function of the language with greatest q
    augm_factor=$(echo "scale=5 ; ${p_ref[$max]}/${q_ref[$max]}" | bc)
    # increase proportion of instances of each language by making the largest fraction in q equal to 1
    for key in "${!q_ref[@]}"
    do
        q_ref[$key]=$(echo "scale=5 ; ${q_ref[$key]}*$augm_factor" | bc)
    done

    echo '('
    for key in "${!q_ref[@]}" ; do
    echo "[$key]=${q_ref[$key]}"
    done
    echo ')'    
}

function get_q_sentences_by_lang() {
    lang=$1
    q_i=$2
    target_corpus=$3
    # total number of sentences in target corpus
    n=$(wc -l < "$target_corpus")

    # number of sentences to mine from target corpus using q
    q_n=$(echo "$q_i*$n/1" | bc)
    grep "#$lang#" $target_corpus | shuf -n $q_n -r
}
