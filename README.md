## VSC demo - Llama 3.2-3B CLI chat

Chat interface for the VSC HPC cluster using Ollama and Llama 3.2-3B.

Some warnings about using the steps below:
    1. This setup relies on the VSC interactive sessions. One benefit of this is that it does not use any credits, but we cannot change the GPU or memory settings as precisely as we can in regular slurm jobs.
    2. You need a vsc account (vscXXXXX), preferably with some credits (the default project account requires access control, so let one of the augment admins add you to the group)
    3. 
    
### Login

```bash

ssh vscXXXXX@login.hpc.kuleuven.be

### Basic navigation

```bash

pwd

cd $VSC_DATA, $VSC_SCRATCH, cd $VSC_HOME

myqouta
sam-balance
srun ...

    
### Setup

```bash
cd $VSC_DATA
git clone <your-repo-url>
cd vsc-llm-demos
./setup.sh
source ~/.bashrc

What setup does:
  - Creates directories in $VSC_SCRATCH (~2GB for container + models)
  - Builds Ollama container (~5 minutes, one-time only)
  - Configures your environment

### Usage

Start interactive session

vsc-llm-start [account]  # Default: lp_augment

Chat with LLM

vsc-llm-chat

Stop server

vsc-llm-stop


organization

- bin/ - Executable scripts
- config/ - Apptainer container definition
- Models stored in $VSC_SCRATCH/vsc-llm/models/
- Container in $VSC_SCRATCH/vsc-llm/containers/
