#!/bin/bash
set -e

echo "════════════════════════════════════════"
echo "  VSC-RAG Setup"
echo "════════════════════════════════════════"
echo ""

# Auto-detect VSC environment variables
if [[ "$HOME" =~ /user/leuven/([0-9]{3})/vsc([0-9]{5}) ]]; then
    SITE="${BASH_REMATCH[1]}"
    USERID="${BASH_REMATCH[2]}"
    export VSC_HOME="/user/leuven/$SITE/vsc$USERID"
    export VSC_DATA="/data/leuven/$SITE/vsc$USERID"
    export VSC_SCRATCH="/scratch/leuven/$SITE/vsc$USERID"

    echo "Detected VSC user: vsc$USERID"
else
    echo "Error: Could not detect VSC user from HOME path"
    echo "HOME=$HOME"
    exit 1
fi

# Get the directory where this script is located (the repo)
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Setup directories in scratch (large storage)
export VSC_RAG_ROOT="${VSC_SCRATCH}/vsc-rag-data"
echo "VSC_RAG_ROOT: $VSC_RAG_ROOT"
echo ""

# Create directory structure
echo "Creating directories..."
mkdir -p "${VSC_RAG_ROOT}/venv"
mkdir -p "${VSC_RAG_ROOT}/containers"
mkdir -p "${VSC_RAG_ROOT}/index"
mkdir -p "${VSC_RAG_ROOT}/config"

# Save repo path for scripts to find python files
echo "$REPO_DIR" > "${VSC_RAG_ROOT}/config/repo_path"

# Setup Python virtual environment
echo "Setting up Python environment..."
module load Python/3.11.3-GCCcore-12.3.0
python -m venv "${VSC_RAG_ROOT}/venv"
source "${VSC_RAG_ROOT}/venv/bin/activate"

echo "Installing Python packages..."
pip install --upgrade pip
pip install -r "${REPO_DIR}/python/requirements.txt"

# Build Apptainer container
echo ""
echo "Building Ollama container (this may take 5-10 minutes)..."

# CRITICAL: Set cache/tmp BEFORE building to avoid disk quota issues
export APPTAINER_CACHEDIR="${VSC_SCRATCH}/apptainer_cache"
export APPTAINER_TMPDIR="${VSC_SCRATCH}/apptainer_tmp"
mkdir -p "$APPTAINER_CACHEDIR" "$APPTAINER_TMPDIR"

apptainer build --fakeroot \
    "${VSC_RAG_ROOT}/containers/ollama.sif" \
    "${REPO_DIR}/config/ollama.def"

echo ""
echo "════════════════════════════════════════"
echo "  Setup Complete!"
echo "════════════════════════════════════════"
echo ""
echo "Add to your ~/.bashrc:"
echo ""
echo "  export VSC_RAG_ROOT=\"${VSC_RAG_ROOT}\""
echo "  export PATH=\"\${VSC_RAG_ROOT}/\$(cat \${VSC_RAG_ROOT}/config/repo_path)/bin:\$PATH\""
echo ""
echo "Then run: source ~/.bashrc"
echo ""
echo "Next steps:"
echo "  1. Request GPU: srun --account=lp_augment --cluster=wice --nodes=1 --ntasks=1 --cpus-per-task=4 --gpus-per-node=1 --time=04:00:00 --pty bash"
echo "  2. Start server: vsc-rag-start"
echo "  3. Index docs:   vsc-rag-index \$VSC_DATA/my-documents"
echo "  4. Chat:         vsc-rag-chat"
echo "════════════════════════════════════════"
