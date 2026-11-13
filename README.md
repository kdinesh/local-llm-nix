# local-llm-nix

Install llama.cpp and run local LLMs using nix flake. Purpose of this demo is to allow users to install and try out LLMs locally.

# How to use

* Install [nix](https://nixos.org/download/), Multi-user installation recommended. You can also check `slides/slides.md` to see how to do this.
* Clone this repo locally using `git clone https://github.com/kdinesh/local-llm-nix`
* Based on your machine `cd` to one of the folders in the repo.
* To know if your machine has a GPU, do `nix run nixpkgs#fastfetch`.

|Folder | Machine |
|----- | ---- |
|`linux-intel` | Linux (no GPU, intel GPU)|
|`linux-amd` | Linux (AMD GPU)|
|`linux-cuda` | Linux (Nvidia GPU, any CPU)|
|`mac` | Mac (M1, M2, M3, M4, M5)|

* Do `nix develop` in the directory chosen above for installation.
* The install will take about 10-20 minutes depending on your machine and internet speed.
* Test your installation by running a small quantized model (say Qwen 3). To do
  this,
    - Download [this](https://huggingface.co/unsloth/Qwen3-8B-GGUF/resolve/main/Qwen3-8B-Q2_K_L.gguf?download=true) file. **Warning**: 3.5 GB
    - Save the file in `~/models` directory.
    - In the shell where you ran `nix develop`, issue the following
      `llama-server --models-dir ~/models --port 8080`
    - Open `http://localhost:8080` in your web browser, to get the chat web interface.
    
