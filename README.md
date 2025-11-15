## VSC demo - Llama 3.2-3B CLI chat

Chat interface for the VSC HPC cluster using Ollama and Llama 3.2-3B.

## Setup

```bash
git clone <your-repo-url>
cd vsc-llm
./setup.sh
source ~/.bashrc

Usage

Start interactive session

vsc-llm-start [account]  # Default: lp_augment

Chat with LLM

vsc-llm-chat

Stop server

vsc-llm-stop

Requirements

- VSC account with GPU access
- Apptainer/Singularity available
- Credit account for SLURM jobs

Structure

- bin/ - Executable scripts
- config/ - Apptainer container definition
- Models stored in $VSC_SCRATCH/vsc-llm/models/
- Container in $VSC_SCRATCH/vsc-llm/containers/
