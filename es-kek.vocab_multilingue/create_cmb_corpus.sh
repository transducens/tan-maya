#!/bin/bash

home=/neural/alou
langs=kek
echo LENGUAGE: $langs ##################################

# compute p as shown in Conneau & Lampert
# https://proceedings.neurips.cc/paper/2019/file/c04c19c2c2474dbf5f7ac4372c5b9af1-Paper.pdf

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
    max="yua"

    for lang in $langs
    do
        if (( $(echo "${q[$lang]} > ${q[$max]}" | bc -l) )) #[ ${q[$lang]} -gt ${q[$max]} ]
        then
            max=$lang
        fi
    done

    augm_factor=$(echo "scale=5 ; ${p[$max]}/${q[$max]}" | bc)

    for key in "${!q[@]}"
    do
        q[$key]=$(echo "scale=5 ; ${q[$key]}*$augm_factor" | bc)
    done

}

if [ -e cmb ]
then
	echo YA HAY UNA CARPETA CMB. VOY A BORRARLA ###################################
	rm -r cmb
fi

echo BORRADO ################################################

dirs="train dev test" # test/JW300
for dir in $dirs
do
	echo CREANDO LOS DIRECTORIOS #########################################
    mkdir -p cmb/$dir
done

# Create test and dev sets using 1000 sentences from each vocabulary, if available
echo ################ ITERANDO #############################
for lang in $langs
do
    if [ -d $home/corpora_mayas/$lang/dataframes ]
    then
        mkdir -p cmb/test/$lang
	echo ENCONTRÉ UN CORPUS PARA $lang ###################################
        shuf $home/corpora_mayas/$lang/dataframes/vocabulario.csv > cmb/test/$lang/vocabulario.shuf
        
        vocab="cmb/test/$lang/vocabulario.shuf"
        
        head -1000 $vocab | cut -f4 > cmb/test/$lang/data.$lang
        head -1000 $vocab | cut -f5 > cmb/test/$lang/data.es

        # if nb of lines in vocab > 2000, take the next 1000 lines, put them in dev, and then put the remainder in train
        if [ $(wc -l < $vocab) -ge 2000 ]
        then
            tail +1001 $vocab | head -1000 | cut -f4 >> cmb/dev/data.cmb
            tail +1001 $vocab | head -1000 | cut -f5 >> cmb/dev/data.es

            tail +2001 $vocab | cut -f4 | sed -e 's/$/ #'$lang'#/' >> cmb/train/data.cmb
            tail +2001 $vocab | cut -f5 >> cmb/train/data.es

        # else, take the remaining lines and put them all in dev
        else
            tail -1000 $vocab | cut -f4 >> cmb/dev/data.cmb
            tail -1000 $vocab | cut -f5 >> cmb/dev/data.es

        fi
    fi
    if [ -e cmb/test/$lang/vocabulario.shuf ]
    then
        rm cmb/test/$lang/vocabulario.shuf
    fi
done

echo DIZQUE YA HE CREADO LOS DATOS ####################################

# tzh needs its own thing because it was not mined from the same sources as the other vocabs

# mkdir cmb/test/tzh
# shuf ~/corpora_mayas/tzh/vocabulario.tzh-es > cmb/test/tzh/vocabulario.shuf

# vocab="cmb/test/tzh/vocabulario.shuf"

# head -1000 $vocab | cut -f1 > cmb/test/tzh/data.tzh
# head -1000 $vocab | cut -f2 > cmb/test/tzh/data.es

# tail +1001 $vocab | tail -1000 | cut -f1 >> cmb/dev/data.cmb
# tail +1001 $vocab | tail -1000 | cut -f2 >> cmb/dev/data.es


# tail +2001 $vocab | cut -f1 | sed -e 's/$/ #tzh#/' >> cmb/train/data.cmb
# tail +2001 $vocab | cut -f2 >> cmb/train/data.es

# rm $vocab


# Create train set
for lang in $langs
do
    for corpus in mozilla bible tatoeba
    do
        if [ -d $home/corpora_mayas/$lang/$corpus ]
        then
            cat $home/corpora_mayas/$lang/$corpus/data.$lang | sed -e 's/$/ #'$lang'#/' >> cmb/train/data.cmb
            cat $home/corpora_mayas/$lang/$corpus/data.es >> cmb/train/data.es
        fi
    done
done

for lang in $langs
do
	if [ -d $home/corpora_mayas/$lang/jw ]
	then
		head -300 $home/corpora_mayas/$lang/jw/data.$lang > cmb/test/$lang/jw.$lang
		head -300 $home/corpora_mayas/$lang/jw/data.es > cmb/test/$lang/jw.es
		tail +301 $home/corpora_mayas/$lang/jw/data.$lang | sed -e 's/$/ #'$lang'#/' >> cmb/train/data.cmb
		tail +301 $home/corpora_mayas/$lang/jw/data.es >> cmb/train/data.es
	fi
done

#declare -A p=$(get_p cmb/train/data.cmb)
#declare -A q=$(get_q 0.7 cmb/train/data.cmb)
#normalise_q
#paste cmb/train/data.cmb cmb/train/data.es | shuf > cmb/train/data.cmb-es

#for lang in $langs
#do
#    get_q_sentences_by_lang $lang ${q[$lang]} cmb/train/data.cmb-es >> cmb/train/data.cmb-es.augmented
#done

#cut -f1 cmb/train/data.cmb-es.augmented > cmb/train/data.cmb
#cut -f2 cmb/train/data.cmb-es.augmented > cmb/train/data.es
#rm cmb/train/data.cmb-es*

# Remove lang token
sed -i 's/ #.*#$//' cmb/train/data.cmb

# Remove trailing period (.)

for dir in train dev
do
    for file in cmb/$dir/*
    do
        cat $file | sed -e "s/\.$//" > $file.temp
        mv $file.temp $file
    done
done
sed -i "s/\.//" cmb/test/kek/data.kek
# mv cmb/train/train.maya-es.bpe cmb/train/train.maya-es

# # Create dev set
# if [ -e cmb/dev ]
# then
#     rm -r cmb/dev
# fi
# mkdir -p cmb/dev

# dev_size=$(echo "$(wc -l<cmb/train/train.maya-es)*.1/1" | bc)

# head -$dev_size cmb/train/train.maya-es > cmb/dev/dev.maya-es
# tail +$dev_size cmb/train/train.maya-es > cmb/train/temp
# mv cmb/train/temp cmb/train/train.maya-es

# cut cmb/train/train.maya-es -f 1 > cmb/train/train.cmb
# cut cmb/train/train.maya-es -f 2 > cmb/train/train.es
# rm cmb/train/train.maya-es
# sed -i 's/ #.*#$//' cmb/train/train.cmb

# #cut cmb/dev/dev.maya-es -f 1 > cmb/dev/dev.cmb
# #cut cmb/dev/dev.maya-es -f 2 > cmb/dev/dev.es
# #rm cmb/dev/dev.maya-es
# #sed -i 's/ #.*#$//' cmb/dev/dev.cmb

# # Create test sets
# for lang in $langs
# do
#     jw300=$lang/test/JW300/test
#     vocab=$lang/test/vocab/test
    
#     if [ -e $jw300.$lang ]
#     then
#         mkdir cmb/test/JW300/$lang
#         cp $jw300.$lang $jw300.es cmb/test/JW300/$lang
#     fi

#     if [ -e $vocab.$lang ]
#     then
#         mkdir cmb/test/vocab/$lang
#         cp $vocab.$lang $vocab.es cmb/test/vocab/$lang
#     fi
# done

# # Remove identifying tokens from corpora
