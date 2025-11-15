#!/bin/bash
set -e

echo "============================================"
echo "  VSC-LLM Setup Wizard"
echo "============================================"
echo ""

# Auto-detect VSC paths
if [ -z "$VSC_SCRATCH" ]; then
  echo "⚠️  VSC environment variables not set."
  echo "Attempting to auto-detect paths..."

  if [[ "$HOME" =~ /user/leuven/([0-9]{3})/vsc([0-9]{5}) ]]; then
      VSC_GROUP="${BASH_REMATCH[1]}"
      VSC_USER="vsc${BASH_REMATCH[2]}"
      export VSC_HOME="/user/leuven/${VSC_GROUP}/${VSC_USER}"
      export VSC_DATA="/data/leuven/${VSC_GROUP}/${VSC_USER}"
      export VSC_SCRATCH="/scratch/leuven/${VSC_GROUP}/${VSC_USER}"
      echo "✓ Detected VSC user: ${VSC_USER}"
  else
      echo "❌ Could not auto-detect VSC paths."
      exit 1
  fi
fi

# Get the actual directory where this repo is cloned
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "✓ Repository location: ${REPO_DIR}"

# Set up environment - use generic name for scratch storage
export VSC_LLM_ROOT=${VSC_SCRATCH}/vsc-llm-data
echo "✓ Using VSC_LLM_ROOT: ${VSC_LLM_ROOT}"

# Create directories
mkdir -p ${VSC_LLM_ROOT}/{containers,models,cache,tmp,config}
echo "✓ Created directory structure"

# Save repo location to config file
echo "${REPO_DIR}" > ${VSC_LLM_ROOT}/config/repo_path
echo "✓ Saved repository path"

# Add to bashrc if not already there
if ! grep -q "VSC_LLM_ROOT" ~/.bashrc 2>/dev/null; then
  echo ""
  echo "Adding VSC-LLM configuration to ~/.bashrc..."
  cat >> ~/.bashrc << 'BASHRC'

# VSC-LLM Configuration (auto-generated)
if [[ "$HOME" =~ /user/leuven/([0-9]{3})/vsc([0-9]{5}) ]]; then
  VSC_GROUP="${BASH_REMATCH[1]}"
  VSC_USER="vsc${BASH_REMATCH[2]}"
  export VSC_HOME="/user/leuven/${VSC_GROUP}/${VSC_USER}"
  export VSC_DATA="/data/leuven/${VSC_GROUP}/${VSC_USER}"
  export VSC_SCRATCH="/scratch/leuven/${VSC_GROUP}/${VSC_USER}"
  export VSC_LLM_ROOT=${VSC_SCRATCH}/vsc-llm-data
  export APPTAINER_CACHEDIR=${VSC_LLM_ROOT}/cache
  export APPTAINER_TMPDIR=${VSC_LLM_ROOT}/tmp

  # Add repo bin to PATH if repo path is saved
  if [ -f "${VSC_LLM_ROOT}/config/repo_path" ]; then
      VSC_LLM_REPO=$(cat "${VSC_LLM_ROOT}/config/repo_path")
      export PATH="${VSC_LLM_REPO}/bin:${PATH}"
  fi
fi
BASHRC
  echo "✓ Updated ~/.bashrc"
fi

# Build container if needed
if [ ! -f ${VSC_LLM_ROOT}/containers/ollama.sif ]; then
  echo ""
  echo "Building Ollama container (this takes ~5 minutes)..."
  cd ${VSC_LLM_ROOT}/containers
  apptainer build --fakeroot ollama.sif ${REPO_DIR}/config/ollama.def
  echo "✓ Container built successfully"
else
  echo "✓ Container already exists"
fi

echo ""
echo "============================================"
echo "  ✓ Setup Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Run: source ~/.bashrc"
echo "  2. Run: vsc-llm-start"
echo "  3. Wait for GPU job to start"
echo "  4. Run: vsc-llm-chat"
echo ""
