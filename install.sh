#!/usr/bin/env bash

module load python

rm -rf gspl.venv
python -m venv gspl.venv

source gspl.venv/bin/activate

pip install --upgrade pip setuptools wheel

pip install git+https://github.com/mjkramer/zeroworker.git

# The following doesn't install dotlockfile. INVESTIGATE!
# git clone https://github.com/mjkramer/zeroworker.git
# ( cd zeroworker && pip install -e . )
