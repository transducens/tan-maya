#!/usr/bin/bash

source scripts/preprocess_corpora.sh
source scripts/train_model.sh
source scripts/evaluate_model.sh

set -e
home=/neural/alou/
langs=$(ls $home/corpora_mayas)

# Preprocess corpora and extract lang token from dataset

echo "Detaching language tokens from train set"
cut cmb/train/data.es -d '#' -f1 > cmb/train/data.notoken
cut cmb/train/data.es -d '#' -f2 > cmb/train/lang_tokens
mv cmb/train/data.notoken cmb/train/data.es

tokenize cmb train cmb/train

learn_truecaser cmb

apply_truecaser cmb train cmb/train

learn_joint_bpe cmb 60000
apply_bpe cmb train cmb/train

echo "Reattaching language tokens to train set"
sed -i "s/$/ /" cmb/train/data.bpe.es 
paste -d '#' cmb/train/data.bpe.es cmb/train/lang_tokens | sed "s/$/#/" > cmb/train/data.langtoken
mv cmb/train/data.langtoken cmb/train/data.bpe.es
rm cmb/train/lang_tokens

echo "Detaching lang tokens from dev set"
cut cmb/dev/data.es -d '#' -f1 > cmb/dev/data.notoken
cut cmb/dev/data.es -d '#' -f2 > cmb/dev/lang_tokens
mv cmb/dev/data.notoken cmb/dev/data.es

tokenize cmb dev cmb/dev
apply_truecaser cmb dev cmb/dev
apply_bpe cmb dev cmb/dev

echo "Reattaching language tokens to dev set"
sed -i "s/$/ /" cmb/dev/data.bpe.es 
paste -d '#' cmb/dev/data.bpe.es cmb/dev/lang_tokens | sed "s/$/#/" > cmb/dev/data.langtoken
mv cmb/dev/data.langtoken cmb/dev/data.bpe.es
rm cmb/dev/lang_tokens


for lang in $langs
do
	if [ -e $home/corpora_mayas/$lang/dataframes/vocabulario.csv ]
	then
		echo "Detaching lang tokens from $lang test set"
		cut cmb/test/$lang/data.es -d '#' -f1 > cmb/test/$lang/data.notoken
		cut cmb/test/$lang/data.es -d '#' -f2 > cmb/test/$lang/lang_tokens
		mv cmb/test/$lang/data.notoken cmb/test/$lang/data.es

	    	tokenize_test $lang 
    		apply_truecaser_test $lang 
	    	apply_bpe_test $lang
		echo "Reattaching lang tokens to $lang test set"
		sed -i "s/$/ /" cmb/test/$lang/data.bpe.es
		paste -d '#' cmb/test/$lang/data.bpe.es cmb/test/$lang/lang_tokens | sed "s/$/#/" > cmb/test/$lang/data.langtoken
		mv cmb/test/$lang/data.langtoken cmb/test/$lang/data.bpe.es
		rm cmb/test/$lang/lang_tokens

    fi
done

# Train model
train_model cmb

# Evaluate model

#for lang in $langs
#do
#    if [ -d $home/corpora_mayas/$lang/dataframes ]
#    then
#    	echo "############### Building report for $lang ###################"
#    	translate_test $lang

#    	rebuild_output $lang

#    	report $lang
#    	echo "############### Finished report for $lang ###################"
#    fi
#done

# Gather all reports and output BLEU scores

#if [ -e bleu_scores ]
#then
#	rm bleu_scores
#fi
#
#for lang in $langs
#do
#		if [ -e cmb/evaluation/$set/$lang ]
#		then
#			bleu=$(head -1 cmb/evaluation/$set/$lang/report | cut -d " " -f 3)
#			echo $lang : $bleu >> bleu_scores
#		fi
#done
