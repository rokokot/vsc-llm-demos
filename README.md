## VSC LLM Demos

Chat and RAG samples for using ollama on the vsc cluster. Default using llama3.2:3b and basic .txt indexing.


#### [vsc-llm](./vsc-llm) - simple chat
#### [vsc-rag](./vsc-rag) - document QA
- **resources**: Interactive GPU (free tier, MIG slice)

```bash
# clone repository
cd $VSC_DATA
git clone https://github.com/rokokot/vsc-llm-demos.git
cd vsc-llm-demos

# chat:
cd vsc-llm && bash setup.sh

# QA:
cd vsc-rag && bash setup.sh
```

### requirements

- VSC account with wICE cluster access (e.g., `vscXXXXX`)
- GPU credit account (e.g., `lp_augment`)

#### GPU configuration

**MIG (Multi-Instance GPU)** on interactive partition:
- **VRAM**: ~10GB per MIG slice
- **Context**: 2048 tokens (reduced from 131K default)
- **Custom model**: `llama3.2-3b-rag` automatically created on first run

The `vsc-rag-start` script automatically:
1. Downloads base model `llama3.2:3b` (~2GB)
2. Creates custom model with 2048 token context
3. This prevents out-of-memory errors on MIG GPUs

### GPU Not Detected

Requires `/local_scratch` bind mount (need to run start scripts).

##### Python Environment

Load Python module in interactive sessions:
```bash
module load Python/3.11.3-GCCcore-12.3.0
```

- [Ollama](https://ollama.com)
- [LlamaIndex](https://www.llamaindex.ai)
- [Llama](https://llama.meta.com)
- [VSC](https://www.vscentrum.be)
