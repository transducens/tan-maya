#!/usr/bin/bash

source scripts/evaluate_model.sh

langs=$(ls /neural/alou/corpora_mayas)
checkpoints=$(ls cmb/model/checkpoints)

if [ -d checkpoint_lang_iter ]
then
	rm checkpoint_lang_iter
fi

mkdir checkpoint_lang_iter
for lang in $langs
do
	if [ -d cmb/test/$lang ]
	then
		mkdir checkpoint_lang_iter/$lang
		for checkpoint in $checkpoints
		do
			mkdir checkpoint_lang_iter/$lang/$checkpoint
			translate_test $lang checkpoint_lang_iter/$lang/$checkpoint $checkpoint
			rebuild_output $lang checkpoint_lang_iter/$lang/$checkpoint
			report $lang checkpoint_lang_iter/$lang/$checkpoint
		done
	fi
done
