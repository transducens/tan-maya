moses_scripts=$HOME/tan-maya/submodules/moses-scripts/scripts
detruecaser=$moses_scripts/recaser/detruecase.perl
detokenizer=$moses_scripts/tokenizer/detokenizer.perl

translate () {
    source_data=$1
    model_dir=$2
    checkpoint=$3
    target_dir=$4

    CUDA_VISIBLE_DEVICES=0 fairseq-interactive --input $source_data --path $model_dir/checkpoints/$checkpoint $model_dir | grep '^H-' | cut -f 3 > $target_dir/data.output-train    

}

rebuild_output () {
    translation_output=$1
    target_dir=$2

    cat $translation_output | sed -r 's/(@@ )|(@@ ?$)//g' > $target_dir/data.output-train.debpe
    cat $target_dir/data.output-train.debpe | $detruecaser > $target_dir/data.output-train.detruecased
    cat $target_dir/data.output-train.detruecased | $detokenizer -l es > $target_dir/data.output-train.detokenized
}

create_report () {
    input=$1
    expected=$2
    target_dir=$3

    cat $input | sacrebleu $expected --width 3 --metrics bleu chrf > $target_dir/report
}
