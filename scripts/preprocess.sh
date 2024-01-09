    moses_scripts=submodules/moses-scripts/scripts

normalizer=$moses_scripts/tokenizer/normalize-punctuation.perl
tokenizer=$moses_scripts/tokenizer/tokenizer.perl
detokenizer=$moses_scripts/tokenizer/detokenizer.perl
clean_corpus=$moses_scripts/training/clean-corpus-n.perl
train_truecaser=$moses_scripts/recaser/train-truecaser.perl
truecaser=$moses_scripts/recaser/truecase.perl
detruecaser=$moses_scripts/recaser/detruecase.perl

tokenize() {
    target=$1
    suffix=${target##*.}
    prefix=$(dirname ${target})
    cat $target | $normalizer -l $suffix | $tokenizer -a -no-escape -l $suffix > $prefix/data.tok.$suffix
}

learn_truecaser() {
    target=$1
    suffix=${target##*.}
    prefix=$(dirname ${target})
    mkdir -p $prefix/truecaser
    $train_truecaser -corpus $target -model $prefix/truecaser/truecase-model.$suffix
}

apply_truecaser () {
    echo "#### LOG" > log
    echo $(date) >> log
    target=$1
    suffix=${target##*.}
    prefix=$(dirname ${target})
    
    if [ -z $2 ]
    then
        model=$prefix/truecaser/truecase-model.$suffix
    else
        model=$2
    fi
    
    echo target: $target >> log
    echo suffix: $suffix >> log
    echo prefix: $prefix >> log
    echo model: $model >> log
    cat $target | $truecaser -model $model > $prefix/data.truecase.$suffix
}

learn_joint_bpe () {
    target_1=$1
    target_2=$2
    suffix_1=${target_1##*.}
    suffix_2=${target_2##*.}
    if [ -z $3 ]
    then
        operations=60000
    else
        operations=$3
    fi
    prefix=$(dirname ${target_1})
    mkdir -p $prefix/bpe
    subword-nmt learn-joint-bpe-and-vocab --input $target_1 $target_2 -s $operations -o $prefix/bpe/vocab.$suffix_1-$suffix_2.bpe --write-vocabulary $prefix/bpe/vocab.$suffix_1-$suffix_2.bpe.vocab.$suffix_1 $prefix/bpe/vocab.$suffix_1-$suffix_2.bpe.vocab.$suffix_2
}

apply_bpe () {
    target_1=$1
    target_2=$2
    
    if [ -z $3 ]
    then
        suffix_1=${target_1##*.}
        lang_1=$suffix_1
    else
        suffix_1=$3
        lang_1=${target_1##*.}
    fi
    
    if [ -z $4 ]
    then
        suffix_2=${target_2##*.}
        lang_2=$suffix_2
    else
        suffix_2=$4
        lang_2=${target_2##*.}
    fi

    if [ -z $5 ]
    then
        prefix=$(dirname ${target_1})
        target_prefix=$prefix
    else
        prefix=$5
        target_prefix=$(dirname ${target_1})
    fi

    cat $target_1 | subword-nmt apply-bpe --vocabulary $prefix/bpe/vocab.$suffix_1-$suffix_2.bpe.vocab.$suffix_1 --vocabulary-threshold 1 -c $prefix/bpe/vocab.$suffix_1-$suffix_2.bpe > $target_prefix/data.bpe.$lang_1

    cat $target_2 | subword-nmt apply-bpe --vocabulary $prefix/bpe/vocab.$suffix_1-$suffix_2.bpe.vocab.$suffix_2 --vocabulary-threshold 1 -c $prefix/bpe/vocab.$suffix_1-$suffix_2.bpe > $target_prefix/data.bpe.$lang_2
}