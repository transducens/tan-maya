#!/usr/bin/bash

source scripts/evaluate_model.sh

langs=$(ls cmb/test/)
checkpoints=$(ls cmb/model/checkpoints)

#if [ -d checkpoint_lang_iter ]
#then
#	rm checkpoint_lang_iter
#fi
#
#mkdir checkpoint_lang_iter
for lang in $langs
do
#	mkdir checkpoint_lang_iter/$lang
#	for checkpoint in $checkpoints
#	do
#		mkdir checkpoint_lang_iter/$lang/$checkpoint
#		echo Translating $lang at $checkpoint
#		translate_test $lang checkpoint_lang_iter/$lang/$checkpoint $checkpoint dev
#		echo Rebuilding translation
#		rebuild_output $lang checkpoint_lang_iter/$lang/$checkpoint dev
#		report $lang checkpoint_lang_iter/$lang/$checkpoint dev
#		echo Done
#	done
    best_checkpoint=$(python get_best_checkpoint_per_language.py | grep "#$lang#" | cut -d " " -f2)
    translate_test $lang cmb/evaluation/$lang $best_checkpoint test
    rebuild_output $lang cmb/evaluation/$lang test
    report $lang cmb/evaluation/$lang test
done
