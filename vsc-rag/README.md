## RAG - document QA

#### 1. Setup (15 minutes, one-time)

```bash
cd $VSC_DATA
git clone https://github.com/rokokot/vsc-llm-demos.git
cd vsc-llm-demos/vsc-rag
bash setup.sh
```

Add to your `~/.bashrc` (replace with your paths):
```bash
export VSC_RAG_ROOT="${VSC_SCRATCH}/vsc-rag-data"
export PATH="${VSC_RAG_ROOT}/$(cat ${VSC_RAG_ROOT}/config/repo_path)/bin:$PATH"
module load Python/3.11.3-GCCcore-12.3.0
```

Then: `source ~/.bashrc`

### 2. request interactive GPU 

```bash
srun --account=CREDIT_ACCOUNT --cluster=wice --partition=interactive \
     --nodes=1 --gpus-per-node=1 --cpus-per-task=4 --mem=16G \
     --time=4:00:00 --pty bash -l
```

### 3. index 

```bash
vsc-rag-start
vsc-rag-index $VSC_DATA/your-documents
```

**Demo**:  included Pascal collected works:
```bash
vsc-rag-index $VSC_DATA/vsc-llm-demos/vsc-rag/pascal-texts
```

### 4. chat

```bash
vsc-rag-chat
```

Type `exit` to quit.