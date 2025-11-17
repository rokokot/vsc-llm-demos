## Llama 3.2-3B CLI chat

#### Login

```bash

ssh vscXXXXX@login.hpc.kuleuven.be

```bash

pwd

cd $VSC_DATA, $VSC_SCRATCH, cd $VSC_HOME

myqouta
sam-balance
srun ...

    
### Setup

```bash
cd $VSC_DATA
git clone <repo-url>
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
