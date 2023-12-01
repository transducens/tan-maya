#!/usr/bin/bash

source scripts/preprocess_corpora.sh
source scripts/train_model.sh
source scripts/evaluate_model.sh

set -e

langs=kek

# Preprocess corpora
#tokenize cmb train cmb/train
#
#learn_truecaser cmb
#
#apply_truecaser cmb train cmb/train
#
##learn_joint_bpe cmb 60000
#apply_bpe cmb train cmb/train
#
#tokenize cmb dev cmb/dev
#apply_truecaser cmb dev cmb/dev
#apply_bpe cmb dev cmb/dev
#
#for lang in $langs
#do
#	if [ -e cmb/test/$set/$lang ]
# 	then
#		tokenize_test $lang $set 
# 		apply_truecaser_test $lang $set 
# 		apply_bpe_test $lang $set
# 	fi
# done

# Train model
train_model cmb

# Evaluate model

for lang in $langs
do
 	echo "############### Building report for $lang ###################"
 	translate_test $lang JW300
 	translate_test	 $lang vocab

 	rebuild_output $lang JW300
 	rebuild_output $lang vocab

 	report $lang JW300
 	report $lang vocab
 	echo "############### Finished report for $lang ###################"
done

# # Gather all reports and output BLEU scores

# if [ -e bleu_scores ]
# then
# 	rm bleu_scores
# fi

# for lang in $langs
# do
# 	for set in JW300 vocab
# 	do
# 		if [ -e cmb/evaluation/$set/$lang ]
# 		then
# 			bleu=$(head -1 cmb/evaluation/$set/$lang/report | cut -d " " -f 3)
# 			echo $lang : $bleu >> bleu_scores
# 		fi
# 	done
# done
