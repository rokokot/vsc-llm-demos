# VSC-RAG - Document Question Answering 📚

Ask questions about your research documents using AI on VSC infrastructure.

## What is this?

VSC-RAG lets you chat with your documents (PDFs, text files) using a local AI model. Perfect for:
- Searching through research papers
- Finding specific information in large document collections
- Getting summaries and insights from your text corpus

**Privacy**: Everything runs locally on VSC. No internet, no API calls, GDPR compliant.

## Quick Start

### 1. Setup (10 minutes, one-time)

```bash
# Clone the repo
cd $VSC_DATA
git clone https://github.com/your-username/vsc-llm-suite.git
cd vsc-llm-suite/vsc-rag

# Run setup
bash setup.sh
```

This will:
- Create a Python environment with RAG libraries
- Build an Ollama container for the AI model
- Set up all necessary directories

### 2. Start the Server

Request an interactive GPU session:

```bash
srun --account=lp_augment --cluster=wice --nodes=1 --ntasks=1 --cpus-per-task=4 --gpus-per-node=1 --time=04:00:00 --pty bash
```

Start Ollama (downloads Llama 3.1-8B on first run):

```bash
vsc-rag-start
```

### 3. Index Your Documents

Point to a folder with your documents (.txt or .pdf files):

```bash
vsc-rag-index $VSC_DATA/my-documents
```

This creates a searchable index. Takes a few minutes depending on document count.

### 4. Chat with Your Documents

```bash
vsc-rag-chat
```

Ask questions like:
- "What are the main findings in the papers about X?"
- "Summarize the methodology used in these documents"
- "What did the author say about Y?"

Type `exit` to quit.

## How It Works

**RAG = Retrieval-Augmented Generation**

1. **Indexing**: Your documents are split into chunks and converted to vectors (embeddings)
2. **Retrieval**: When you ask a question, similar chunks are found using semantic search
3. **Generation**: The AI reads those chunks and answers your question

**Technology Stack**:
- **LLM**: Llama 3.1-8B (better reasoning than 3B model)
- **Embeddings**: all-MiniLM-L6-v2 (fast, good quality)
- **Framework**: LlamaIndex (handles all the RAG complexity)
- **Runtime**: Ollama in Apptainer container

## Folder Structure

```
$VSC_DATA/vsc-llm-suite/vsc-rag/    # Your cloned repo
├── bin/                            # Command scripts
│   ├── vsc-rag-start
│   ├── vsc-rag-index
│   └── vsc-rag-chat
├── python/                         # RAG implementation
│   ├── rag_utils.py
│   └── requirements.txt
└── config/
    └── ollama.def                  # Container definition

$VSC_SCRATCH/vsc-rag-data/          # Runtime data
├── venv/                           # Python environment
├── containers/                     # Apptainer container
└── index/                          # Your document index
```

## Updating Your Index

If you add new documents:

```bash
vsc-rag-index $VSC_DATA/my-documents
```

This rebuilds the index from scratch.

## Resource Requirements

- **GPU**: 1x A100 (or any GPU with 16GB+ VRAM)
- **RAM**: ~8GB
- **Storage**:
  - Model: ~4.7GB (Llama 3.1-8B)
  - Index: Depends on document count (~1-10GB typical)
  - Container: ~2GB

## Troubleshooting

**"Error: Container not found"**
- Run `bash setup.sh` first

**"Error: No index found"**
- Run `vsc-rag-index <path-to-docs>` first

**Ollama server not responding**
- Check logs: `cat /tmp/ollama_rag.log`
- Restart: `pkill -f ollama` then `vsc-rag-start`

**Chat is slow**
- Normal! RAG involves: embedding query → searching index → LLM inference
- First response takes ~10-30 seconds depending on document complexity

**Out of memory**
- Reduce `similarity_top_k` in `rag_utils.py` (retrieves fewer chunks)
- Use smaller model (Llama 3.2-3B) by editing `vsc-rag-start`

**Indexing fails on large PDFs**
- PDFs with complex formatting can cause issues
- Convert to .txt format if possible
- Or split large PDFs into smaller files

## Tips

- **Better answers**: Ask specific questions rather than broad ones
- **Context**: The AI only sees chunks retrieved from your documents
- **Model size**: 8B model is much better than 3B for reasoning, worth the extra resources
- **Document quality**: Clean, well-formatted text gives better results than messy PDFs

## Comparison with vsc-llm

| Feature | vsc-llm | vsc-rag |
|---------|---------|---------|
| Model | Llama 3.2-3B | Llama 3.1-8B |
| Use case | General chat | Document Q&A |
| Setup | 5 min | 10 min |
| Memory | ~4GB | ~10GB |
| Speed | Fast | Moderate |
| Documents | No | Yes |

## Credits

Built for VSC users by researchers, for researchers. Uses open-source tools: Ollama, LlamaIndex, Llama models by Meta.
