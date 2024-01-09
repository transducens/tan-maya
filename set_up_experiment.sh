home=/neural/alou
langs=$(ls $home/corpora_mayas)

if [ -d training_runs ]
then
    echo "Cannot run experiments: 'training_runs' folder exists!"
    exit
fi

mkdir -p training_runs

for lang in $langs
do
    cp scripts/train_model.sh training_runs/es-$lang.sh
    cp scripts/train_model.sh training_runs/$lang-es.sh
done

cp scripts/train_model.sh training_runs/es-cmb.sh
cp scripts/train_model.sh training_runs/cmb-es.sh