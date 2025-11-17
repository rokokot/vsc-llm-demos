## RAG - document QA

#### 1. Setup (15 minutes, one-time)

```bash
cd $VSC_DATA
git clone https://github.com/rokokot/vsc-llm-demos.git
cd vsc-llm-demos/vsc-rag
bash setup.sh
```

Add to your `~/.bashrc` (the setup script will show you the exact code):
```bash
# VSC-RAG Configuration
if [[ "$HOME" =~ /user/leuven/([0-9]{3})/vsc([0-9]{5}) ]]; then
  SITE="${BASH_REMATCH[1]}"
  USERID="${BASH_REMATCH[2]}"
  export VSC_SCRATCH="/scratch/leuven/$SITE/vsc$USERID"
  export VSC_RAG_ROOT="${VSC_SCRATCH}/vsc-rag-data"

  # Add repo bin to PATH if repo path is saved
  if [ -f "${VSC_RAG_ROOT}/config/repo_path" ] 2>/dev/null; then
      VSC_RAG_REPO=$(cat "${VSC_RAG_ROOT}/config/repo_path" 2>/dev/null)
      if [ -n "$VSC_RAG_REPO" ] && [ -d "$VSC_RAG_REPO/bin" ]; then
          export PATH="${VSC_RAG_REPO}/bin:${PATH}"
      fi
  fi
fi

# Load Python module for RAG
module load Python/3.11.3-GCCcore-12.3.0
```

Then: `source ~/.bashrc`

### 2. request interactive GPU 

```bash
srun --account=CREDIT_ACCOUNT --cluster=wice --partition=interactive \
     --nodes=1 --gpus-per-node=1 --cpus-per-task=4 --mem=16G \
     --time=4:00:00 --pty bash -l
```

### 3. Start server and index documents

```bash
vsc-rag-start  # Downloads model (~2GB) on first run
vsc-rag-index $VSC_DATA/your-documents
```

**First time:** `vsc-rag-start` will:
- Download base model `llama3.2:3b` (~2GB, one-time)
- Create custom model with 2048 token context (for MIG GPU compatibility)
- This takes ~5 minutes on first run

**Demo**: Try the included Pascal texts:
```bash
vsc-rag-index $VSC_DATA/vsc-llm-demos/vsc-rag/pascal-texts
```

### 4. chat

```bash
vsc-rag-chat
```

Type `exit` to quit.