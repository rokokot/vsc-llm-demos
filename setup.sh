#!/bin/bash
set -e

echo "=== VSC-LLM Setup ==="

# environment setu
export VSC_LLM_ROOT=${VSC_SCRATCH}/vsc-llm
mkdir -p ${VSC_LLM_ROOT}/{containers,models,cache,tmp}

# update shell
if ! grep -q "VSC_LLM_ROOT" ~/.bashrc; then
  cat >> ~/.bashrc << 'BASHRC'

# llm directory config variables
export VSC_LLM_ROOT=${VSC_SCRATCH}/vsc-llm
export APPTAINER_CACHEDIR=${VSC_LLM_ROOT}/cache
export APPTAINER_TMPDIR=${VSC_LLM_ROOT}/tmp
export PATH=${VSC_DATA}/vsc-llm/bin:${PATH}
BASHRC
fi

# check container config
if [ ! -f ${VSC_LLM_ROOT}/containers/ollama.sif ]; then
  echo "running Ollama container..."
  cd ${VSC_LLM_ROOT}/containers
  apptainer build --fakeroot ollama.sif ${VSC_DATA}/vsc-llm/config/ollama.def
fi

echo "setup ok ----> run 'source ~/.bashrc' then 'vsc-llm-start'"
