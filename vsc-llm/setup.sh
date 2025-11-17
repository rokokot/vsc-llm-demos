#!/bin/bash
set -e


echo "  VSC - LLM demo setup"
echo "============================="
echo ""

# auto detect VSC paths
if [ -z "$VSC_SCRATCH" ]; then
  echo "VSC environment variables not set."
  echo "auto-detect paths..."

  if [[ "$HOME" =~ /user/leuven/([0-9]{3})/vsc([0-9]{5}) ]]; then
      VSC_GROUP="${BASH_REMATCH[1]}"
      VSC_USER="vsc${BASH_REMATCH[2]}"
      export VSC_HOME="/user/leuven/${VSC_GROUP}/${VSC_USER}"
      export VSC_DATA="/data/leuven/${VSC_GROUP}/${VSC_USER}"
      export VSC_SCRATCH="/scratch/leuven/${VSC_GROUP}/${VSC_USER}"
      echo "found VSC user: ${VSC_USER}"
  else
      echo "auto-detect VSC paths failed"
      exit 1
  fi
fi

# find actual directory where this repo is cloned
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "repository location: ${REPO_DIR}"

# set up environment - use generic name for scratch storage
export VSC_LLM_ROOT=${VSC_SCRATCH}/vsc-llm-data
echo "using VSC_LLM_ROOT: ${VSC_LLM_ROOT}"

# create directories
mkdir -p ${VSC_LLM_ROOT}/{containers,models,cache,tmp,config}
echo "created directory structure"

# IMPORTANT --> set Apptainer cache to scratch before building
export APPTAINER_CACHEDIR=${VSC_LLM_ROOT}/cache
export APPTAINER_TMPDIR=${VSC_LLM_ROOT}/tmp
echo "set Apptainer cache to scratch (not HOME because of size issues, check myquota for usage)"


# repo location to config file
echo "${REPO_DIR}" > ${VSC_LLM_ROOT}/config/repo_path
echo "saved repo path"

# update bashrc 
if ! grep -q "VSC_LLM_ROOT" ~/.bashrc 2>/dev/null; then
  echo ""
  echo " config --> ~/.bashrc..."
  cat >> ~/.bashrc << 'BASHRC'

# configuration for env vars and paths, auto generated from selected user
if [[ "$HOME" =~ /user/leuven/([0-9]{3})/vsc([0-9]{5}) ]]; then
  VSC_GROUP="${BASH_REMATCH[1]}"
  VSC_USER="vsc${BASH_REMATCH[2]}"
  export VSC_HOME="/user/leuven/${VSC_GROUP}/${VSC_USER}"
  export VSC_DATA="/data/leuven/${VSC_GROUP}/${VSC_USER}"
  export VSC_SCRATCH="/scratch/leuven/${VSC_GROUP}/${VSC_USER}"
  export VSC_LLM_ROOT=${VSC_SCRATCH}/vsc-llm-data
  export APPTAINER_CACHEDIR=${VSC_LLM_ROOT}/cache
  export APPTAINER_TMPDIR=${VSC_LLM_ROOT}/tmp

  # add repo bin to PATH if repo path is saved
  if [ -f "${VSC_LLM_ROOT}/config/repo_path" ] 2>/dev/null; then
      VSC_LLM_REPO=$(cat "${VSC_LLM_ROOT}/config/repo_path" 2>/dev/null)
      if [ -n "$VSC_LLM_REPO" ] && [ -d "$VSC_LLM_REPO/bin" ]; then
          export PATH="${VSC_LLM_REPO}/bin:${PATH}"
      fi
  fi
fi
BASHRC
  echo "updated ~/.bashrc"
fi

# run build container if needed
if [ ! -f ${VSC_LLM_ROOT}/containers/ollama.sif ]; then
  echo ""
  echo "running Ollama container (this takes ~10 minutes)..."
  cd ${VSC_LLM_ROOT}/containers
  apptainer build --fakeroot ollama.sif ${REPO_DIR}/config/ollama.def
  echo "container built successfully"
else
  echo "container already exists"
fi

echo ""
echo "  Setup ok!, continue with next steps"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. --> source ~/.bashrc"
echo "2. --> vsc-llm-start"
echo "3. Wait for GPU job to start"
echo "4. --> vsc-llm-chat"
echo ""
