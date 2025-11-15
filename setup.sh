#!/bin/bash
set -e

echo "  Llama 3.2-3B demo setup"
echo "============================================"
echo ""

# auto-detect VSC paths
if [ -z "$VSC_SCRATCH" ]; then
  echo "environment variables missing"
  echo "try to auto-detect paths..."

  # find user's VSC ID from home directory
  if [[ "$HOME" =~ /user/leuven/([0-9]{3})/vsc([0-9]{5}) ]]; then
      VSC_GROUP="${BASH_REMATCH[1]}"
      VSC_USER="vsc${BASH_REMATCH[2]}"
      export VSC_HOME="/user/leuven/${VSC_GROUP}/${VSC_USER}"
      export VSC_DATA="/data/leuven/${VSC_GROUP}/${VSC_USER}"
      export VSC_SCRATCH="/scratch/leuven/${VSC_GROUP}/${VSC_USER}"
      echo "VSC user: ${VSC_USER}"
  else
      echo "could not auto-detect VSC paths."
      echo ""
      exit 1
  fi
fi

# environment setup
export VSC_LLM_ROOT=${VSC_SCRATCH}/vsc-llm
echo "set VSC_LLM_ROOT: ${VSC_LLM_ROOT}"

# create tree
mkdir -p ${VSC_LLM_ROOT}/{containers,models,cache,tmp}
echo "created directory structure"

# bashrc if not already there
if ! grep -q "VSC_LLM_ROOT" ~/.bashrc 2>/dev/null; then
  echo ""
  echo "Adding VSC-LLM configuration to ~/.bashrc..."
  cat >> ~/.bashrc << 'BASHRC'

# VSC Configuration - auto config
if [[ "$HOME" =~ /user/leuven/([0-9]{3})/vsc([0-9]{5}) ]]; then
  VSC_GROUP="${BASH_REMATCH[1]}"
  VSC_USER="vsc${BASH_REMATCH[2]}"
  export VSC_HOME="/user/leuven/${VSC_GROUP}/${VSC_USER}"
  export VSC_DATA="/data/leuven/${VSC_GROUP}/${VSC_USER}"
  export VSC_SCRATCH="/scratch/leuven/${VSC_GROUP}/${VSC_USER}"
  export VSC_LLM_ROOT=${VSC_SCRATCH}/vsc-llm
  export APPTAINER_CACHEDIR=${VSC_LLM_ROOT}/cache
  export APPTAINER_TMPDIR=${VSC_LLM_ROOT}/tmp
  export PATH=${VSC_DATA}/vsc-llm/bin:${PATH}
fi
BASHRC
  echo " ~/.bashrc ok"
fi

# Build container if needed
if [ ! -f ${VSC_LLM_ROOT}/containers/ollama.sif ]; then
  echo ""
  echo "launchin Ollama container (this takes ~10 minutes)..."
  cd ${VSC_LLM_ROOT}/containers
  apptainer build --fakeroot ollama.sif ${VSC_DATA}/vsc-llm/config/ollama.def
  echo "container built successfully"
else
  echo "container already exists"
fi

echo ""
echo "  setup ok!"

echo ""
echo "Next steps:"
echo "  1. Run: source ~/.bashrc"
echo "  2. Run: vsc-llm-start"
echo "  3. Wait for GPU job to start"
echo "  4. Run: vsc-llm-chat"
echo ""
