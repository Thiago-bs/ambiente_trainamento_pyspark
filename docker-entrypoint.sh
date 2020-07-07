#!/bin/bash

pip install -r requirements.txt
python -m spacy download pt

python setup.py -q develop
sudo sysctl -w vm.max_map_count=262144

if [ "$1" = 'jupyter' ]; then
 jupyter notebook --ip=0.0.0.0 --port=8085 --allow-root \
                               --NotebookApp.notebook_dir='./notebooks' \
                               --NotebookApp.token='' \
                               --NotebookApp.password=''
fi

if [ "$1" = 'bash' ]; then
 /bin/bash
fi
