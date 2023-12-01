#!/usr/bin/bash

source scripts/evaluate_model.sh

langs=$(ls cmb/test/)
checkpoints=$(ls cmb/model/checkpoints)

if [ -d checkpoint_lang_iter ]
then
	rm checkpoint_lang_iter
fi

mkdir checkpoint_lang_iter
for lang in $langs
do
	mkdir checkpoint_lang_iter/$lang
	for checkpoint in $checkpoints
	do
		mkdir checkpoint_lang_iter/$lang/$checkpoint
		echo Translating $lang at $checkpoint
		translate_test $lang checkpoint_lang_iter/$lang/$checkpoint $checkpoint
		echo Rebuilding translation
		rebuild_output $lang checkpoint_lang_iter/$lang/$checkpoint
		report $lang checkpoint_lang_iter/$lang/$checkpoint
		echo Done
	done
done
