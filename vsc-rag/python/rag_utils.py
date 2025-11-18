#!/usr/bin/env python3

""" RAG utility for VSC -  indexing and QA


"""

import os
import sys
from pathlib import Path

def setup_environment(): # environment variables and paths
    home = os.environ.get('HOME', '')
    if not os.environ.get('VSC_SCRATCH'):

        parts = home.split('/')
        if len(parts) >= 5 and parts[1] == 'user' and parts[2] == 'leuven':
            site = parts[3]
            userid = parts[4]
            os.environ['VSC_SCRATCH'] = f'/scratch/leuven/{site}/{userid}'

    vsc_rag_root = os.environ.get('VSC_RAG_ROOT', os.path.join(os.environ.get('VSC_SCRATCH', ''), 'vsc-rag-data'))

    return vsc_rag_root

def build_index(doc_path: str):
    """bild vector index """
    from llama_index.core import VectorStoreIndex, SimpleDirectoryReader, Settings
    from llama_index.llms.ollama import Ollama
    from llama_index.embeddings.huggingface import HuggingFaceEmbedding

    vsc_rag_root = setup_environment()
    index_dir = os.path.join(vsc_rag_root, "index")

    print("Loading documents...")
    # Load all txt and files; extend as necessary
    reader = SimpleDirectoryReader(
        input_dir=doc_path,
        required_exts=[".txt", ".pdf"],

        recursive=True
    )

    documents = reader.load_data()
    print(f"indexed {len(documents)} documents")

    print("setup RAG -> ollama + embeddings ")
    #  LLM (Ollama running locally)
    Settings.llm = Ollama(
        model="llama3.2:3b",
        base_url="http://localhost:11434",
        request_timeout=120.0
    )

    #  embeddings (local HuggingFace model)
    Settings.embed_model = HuggingFaceEmbedding(
        model_name="sentence-transformers/all-MiniLM-L6-v2"
    )

    print("getting vector index (this will take a few minutes)...")
    index = VectorStoreIndex.from_documents(documents, show_progress=True)

    #  index to disk

    os.makedirs(index_dir, exist_ok=True)

    index.storage_context.persist(persist_dir=index_dir)
    print(f"index saved to {index_dir}")

    return index

def load_index():
    """ load existing index from disk"""
    from llama_index.core import load_index_from_storage, StorageContext, Settings
    from llama_index.llms.ollama import Ollama
    from llama_index.embeddings.huggingface import HuggingFaceEmbedding

    vsc_rag_root = setup_environment()
    index_dir = os.path.join(vsc_rag_root, "index")

    # Configure LLM and embeddings (must match indexing settings)

    Settings.llm = Ollama(
        model="llama3.2-3b-rag",
        base_url="http://localhost:11434",
        request_timeout=120.0,
	additional_kwargs={"num_ctx": 2048}
    )


    Settings.embed_model = HuggingFaceEmbedding(
        model_name="sentence-transformers/all-MiniLM-L6-v2"
    )

    # Load index
    storage_context = StorageContext.from_defaults(persist_dir=index_dir)
    index = load_index_from_storage(storage_context)

    return index

def chat_loop():
    """ chat with documents"""
    print("loading index...")
    index = load_index()
    query_engine = index.as_query_engine(similarity_top_k=3)

    print("\n" + "="*60)
    print("  QA interface")
    print("="*60)
    print("  Type 'exit' or 'quit' to end the session")
    print("="*60 + "\n")

    while True:
        try:
            # Get user input
            question = input("\033[1;36mYou: \033[0m").strip()

            if question.lower() in ['exit', 'quit', 'q']:
                print("\nGoodbye!")
                break

            if not question:
                continue

            # Query the index
            print("\033[1;32mAssistant: \033[0m", end='', flush=True)
            response = query_engine.query(question)
            print(str(response))
            print()

        except KeyboardInterrupt:
            print("\n\nGoodbye!")
            break
        except Exception as e:
            print(f"\n\033[1;31mError: {e}\033[0m\n")

def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  rag_utils.py index <doc-path>  -  index from documents")
        print("  rag_utils.py chat              - start RAG chat ")
        sys.exit(1)

    command = sys.argv[1]

    if command == "index":
        if len(sys.argv) < 3:
            print("error: Please provide document path")
            print("Usage: rag_utils.py index <doc-path>")
            sys.exit(1)

        doc_path = sys.argv[2]
        if not os.path.isdir(doc_path):
            print(f"error: Directory not found: {doc_path}")
            sys.exit(1)

        build_index(doc_path)

    elif command == "chat":
        chat_loop()

    else:
        print(f"unknown command: {command}")
        sys.exit(1)

if __name__ == "__main__":
    main()
