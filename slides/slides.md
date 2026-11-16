---
title: Installing and using LLMs locally
author: In-house AI workshop (Day 1) 
institute: A01-007, Academic Building, IIT Palakkad
urlcolor: red
fonttheme: professionalfonts
theme: Copenhagen
colortheme: beaver
date: 18 November 2026
header-includes:
  - \usepackage{amsmath,amssymb,amsthm}
  - \usepackage[ruled,vlined]{algorithm2e}
  - \usepackage{blkarray}
---

# Plan

* Walk-through of installation of softwares

* Rudiments of how inference is done

* **Takeaways**: 
    - Understand which models can be run in your hardware
    - Doing inference locally (esp. less RAM, no GPU)
    - Tradeoffs involved in running them locally

<!---
Add some pictures from previous slides.
-->


# Plan

* **Walk-through of installation of softwares $\gets$ **

* Rudiments of how inference is done

* **Takeaways**: 
    - Understand which models can be run in your hardware
    - Doing inference locally (esp. less RAM, no GPU)
    - Tradeoffs involved in running them locally

<!---
Add some pictures from previous slides.
-->

# Installation of Nix

- Open terminal
    - Linux - `Alt+Ctrl+t` 
    - Mac - `Cmd + space`. Type `terminal`



## **Linux users** (any flavor) 
``` bash
curl -L https://nixos.org/nix/install|sh -s -- --daemon 

```



## **Mac users**: (macOS 14.0 or above)
``` bash
curl -L https://nixos.org/nix/install|sh 

```

## $\to$ **Enter you computer login password when prompted**


# Installation of Nix (Enable flakes)

## Edit the file `/etc/nix/nix.conf`
``` bash
sudo nano /etc/nix/nix.conf

```

## Your should see something like \ldots
``` bash
build-users-group = nixbld

<...>

```

## Add the last line \ldots 

``` bash
build-users-group = nixbld

<...>

experimental-features = nix-command flakes

```

# Installation of Inference (`llama.cpp`)

- Build from source: to enable a few features

- Installs: 
    - `llama.cpp` - inference, (developer: **G**eorgi **G**reganov) 
    - `hf` - huggingface model downloader
    - `pi` - programming agent (developer: Mario Zechner)

- This step: Needs 6-7 GB of HDD/SSD storage space

<!-- llama.cpp purchased by huggingface, which is purchased by Nvidia -->
## Know your hardware !
``` bash
nix run nixpkgs#fastfetch

```  


# Installation of Inference (`llama.cpp`)

- Go to the repo: \url{https://github.com/kdinesh/local-llm-nix/} \pause
- Download the repo as an archive (show how) \pause
- Extract the zip to a folder. Do
    - open `linux-intel`  $\gets$ Linux (no GPU),
    - open `linux-amd`  $\gets$ Linux (AMD GPU),
    - open `linux-cuda` $\gets$ Linux (Nvidia GPU, any CPU), 
    - open `mac` $\gets$  Mac (M1,M2,M3,M4,M5) 
- Right click, "open terminal" in folder (or `cd` to the folder) \pause
- **Type: `nix develop`. Press enter** 

<!--
- Existing software stays unaffected ! You can do Ctrl+C any time you want
-->

# While the installation is going on $\ldots$

- Download intranet copy of Qwen 3 model (3.5 GB)  (show) \pause

- Can also do 

``` bash
hf download unsloth/Qwen3-8B-GGUF \ 
    Qwen3-8B-Q2_K_L.gguf --local-dir ~/models/
```

- Sit back and relax !! \pause

* Inference: how does `llama.cpp` run an LLM ? \pause

* Why bother ? \pause Explain program behaviour (to some extend) \pause

<!-- since we are using a software, it is good to have a mental model of how it
runs so that you are not surprised by its behaviour -->

## Plan 
Calculate **compute** and **memory** usage for a model under **reasonable assumptions**


# Inference - from a Systems PoV

::: columns

:::: column
* Model **vocabulary** of $w$ words (Varies with models)

* Each word =  real vector of length $d$
    - For open models $d=8192$ \pause

* Sentence of $N$ words: viewed as $I$ in $\mathbb{R}^{N \times d}$

* **Aim: find the $N+1$th word**
::::

:::: column

$$
I = \begin{blockarray}{r*{5}{c}}
& 1 & \ldots & d \\
\begin{block}{ >{\scriptstyle}r!{\,}(ccccc)}
1  & \phantom{4} &\phantom{-} & \phantom{5} \\
2  & \phantom{4} &\phantom{-} & \phantom{5} \\
3  & \phantom{4} &\phantom{-} & \phantom{5} \\
\vdots  & \phantom{4} &\phantom{-} & \phantom{5} \\
 &  \phantom{4} &\phantom{-} & \phantom{5} \\
N &  \phantom{4} &\phantom{-} & \phantom{5} \\
\end{block}
\end{blockarray}
$$

::::

:::

\begin{center}
\large Words = Tokens
\end{center}

# Simplified inference algorithm

* $I$ be $N \times d$ real matrix.

* $W_{vocab}$ be a $d \times w$ matrix corresponding to word probabilities

::: columns

:::: column
\begin{algorithm*}[H]
\DontPrintSemicolon
\SetAlgoLined
\SetKwInOut{Input}{Input}\SetKwInOut{Output}{Output}
\Input{$I \in \mathbb{R}^{N \times d}$}
\Output{$(N+1)$th word}
\BlankLine
\For{each layer $t$ in LLM}{
    $I = \mathbf{Attention}_t(I)$
    }
$tk_{prob}$ = softmax($I \cdot W_{vocab}$)

Output word with max $tk_{prob}$ value
\caption{Inference}
\end{algorithm*}  \pause
::::
:::: column
$$
\begin{blockarray}{r*{4}{c}}
& 1 & \ldots & d \\
\begin{block}{ >{\scriptstyle}r!{\,}(cccc)}
1  & &\textcolor{red}{Delete} & &  \\
2  & \phantom{4} &\phantom{-} &  \\
3  & \phantom{4} &\phantom{-} &  \\
\vdots  & \phantom{4} &\phantom{-} & \\
 &  \phantom{4} &\phantom{-} &  \\
N &  \phantom{4} &\phantom{-} &  \\
N+1 &  \phantom{4} & \textcolor{blue}{Added} &  \\
\end{block}
\end{blockarray}
$$


::::
:::

* Next time: output appended to $I$ matrix, first entry drop. Stays $N \times
  d$ matrix


# What is Attention ?

::: {.block}
## What was skipped  ?
(for experts) RoPE[^rope], MLP layers, Token sampling \ldots 

:::

[^rope]: "Rotary Embeddings: A Relative Revolution", [blog link](https://blog.eleuther.ai/rotary-embeddings/)

\pause


\begin{center}
\fbox{$d = 8192$, $I$ = $N \times d$ input matrix}
\end{center}
* Each layer $t$, $W_Q^{(t)}$, $W_K^{(t)}$, $W_V^{(t)}$ - all $d \times d$ matrices

* Let $Q = I \cdot W_Q$, $K = I\cdot W_K$, $V = I \cdot W_V$ \pause

* $\mathbf{Attention}_t(I) =\mathsf{softmax} \left( \frac{Q\cdot K^T}{\sqrt{d}} \cdot  V \right )$ \pause

* **Our focus**: Computing $K, V$ compute --  Multiply $N \times d$ and $d \times d$ matrices




# Compute and memory access for single matrix multiplication

* Number of compute operations - $Nd \times (d+d-1) \le 2Nd^2$

* Number of memory access 
    - Naive: $\approx Nd^2$
    - Tiling[^tile]: $d(N+d) = dN+d^2$ \pause

* $N$ = Context window
    - Typical values - 4096, 32768, 65536, 262144
    - Take $N = 262144$
<!--  $\approx 667$ pages of A4 text (assume 400 words/page and each word is 4/3 token). -->

**To generate the next word (1 token)**

* Number of compute ops = $35.2 \times 10^{12}$ (trillions)
* Number of mem access  = $2.2 \times 10^9$ (billions)

[^tile]: "How to tile matrix multiplication ?", Alvin Wan ([blog link](https://alvinwan.com/how-to-tile-matrix-multiplication/))

## Mind Block !
\textcolor{red}{Several 1000s of cycles wait needed before next layer !}

# Caches to the rescue 

$$
\begin{blockarray}{r*{7}{c}}
\begin{block}{ >{\scriptstyle}r!{\,}(ccccccc)}
I & \textcolor{red}{v_1} & \textcolor{blue}{v_2} & \textcolor{blue}{v_3} & \textcolor{blue}{\ldots} & \textcolor{blue}{v_N} & \\
I_{next} &  & \textcolor{blue}{v_2} & \textcolor{blue}{v_3} & \textcolor{blue}{\ldots} & \textcolor{blue}{v_N} & \textcolor{red}{v_{N+1}}  \\
\end{block}
\end{blockarray}
$$

\pause
* Already computed $2$ \ldots $N$, so cache it (called **KV-cache**) !
* Assume:[^cache]  \textcolor{green}{cache hit of 100\% and take $N=1$}

**To generate the next word (1 token), with $N=1$**

* Number of compute ops = $2d^2 = 134 \times 10^{6}$ (millions)
* Number of mem access  = $d(1+d) = 67  \times 10^6$ (millions)

\pause

::: {.block}
## Takeaway 
Possible to do 2 operations/memory access (on average)

:::


\begin{center}
\textcolor{red}{\textbf{Penality}: Need to maintain KV-cache in memory !}
\end{center}

[^cache]: "How cache works", Huggingface docs repo ([github link](https://github.com/huggingface/transformers/blob/c7e57f79348480f73d3ef0ad8c47f807ef1378c8/docs/source/en/cache_explanation.md)). 

# Trick to reduce memory usage

* Qwen 3 model: 32 $\times 10^9$ (billion) parameters \& 48 layers 

* Assume: \textcolor{green}{each param (floating point) is 1 byte}

* Total KV cache is $\underbrace{2}_{\text{$K$ and $V$}} \times \underbrace{Nd}_{values} \times \underbrace{L}_{\# layers}$

* Memory (Qwen 3) = 206 GB + 32 GB (\textcolor{red}{Too much memory
  !})

* **Solution**: Grouped query attention[^group]. Reduces memory req by factor of $8$

## **Takeaway**: Single user would need $\approx$ 25 GB + 32 GB = 57 GB
Multiuser setting, mechanism very similar to virtual memory
  (PagedAttention)[^paged] works ! Supports multiple users + save more memory !

[^group]: GQA paper,  Google Research, 2023
[^paged]: vLLM, UC Berkeley, 2023

# Lastly: number of tokens per second \ldots

* Memory bandwidth: 50GB/sec (for ordinary CPU)

* \# of Float ops (FLOPS): 1 Tera flop/sec (for ordinary CPU)

* Time to move data: 57G / 50G = 1.8 seconds

* Time for compute: 57G $\times \textcolor{red}{2}$ / 1T = 0.1 seconds

* Factor \textcolor{red}{2}: **Recall: 2 ops/mem access**

\begin{center}
 Tokens / second $\le \frac{1}{\max\{\text{Time move data}, \text{Time compute}\}}$ \pause $\le \textbf{0.56}$
\end{center}


<!-- 
\textbf{A similar calc holds for dense models alone.} \pause
-->

\begin{center}
\fbox{\large The installation should be complete by now. Let's get back ! }

\end{center}



# Running `llama.cpp` in single setup

**Single setup**

* Download the models in `~/models` folder in your home

``` bash
$ llama-server --models-dir ~/models --port 8080 

```

* Open `http://localhost:8080/` to access the web interface

* Load the model from the dropdown


# Running `llama.cpp` in distributed setup - I

**Distributed setup**

* Main machine - `potato1` (less compute)  
* Secondary machine - `potato2` (more compute)

* From `potato1` login to `potato2` and open an ssh tunnel

``` bash
user@potato1 $ ssh -L 50050:localhost:50050 user@potato2

# Enter password for user in potato2
# cd to the folder containing the nix flake file

user@potato2 $ nix develop
user@potato2 $ ggml-rpc-server -c -p "50050" -t 12

```

* Note: replace `potato1`, `potato2` by the IPs


# Running `llama.cpp` in distributed setup - II

* In machine `potato1` run llama.cpp as follows

``` bash
$ llama-server --models-dir ~/models --port 8080 \
    --rpc potato2:50050

```


* For more machines, just do `--rpc potato2:50050,potato3:50051,potato4:50052`

* Note: replace `potato2` by the IPs. Use different port for different machines

# Ways to speed-up inference

* Multi-token prediction
    - Qwen already provides it 
    - Can be found in `unsloth`[^link]
    - To enable in `llama.cpp`, place the MTP files in `~/models` dir

* Flash attention
    - To enable, pass `-fa` as an option

* Turbo llama.cpp
    - Based on Turbo Quant, Google research (ICLR 2026)

[^link]: Unsloth: Qwen3 - How to Run & Fine-tune, [blog link](https://unsloth.ai/docs/models/tutorials/qwen3-how-to-run-and-fine-tune)

# To run MoE models (possible with no GPU)

* Use `colibri`

* Clone the repo: \url{https://github.com/JustVugg/colibri/}

* `cd` to the folder and run `nix develop`

* Execute `./start-here.sh`

* Follow the instructions

## Trade-off
Quality (of output) vs usability (tokens/sec) 

# Reference and pointers

* [How to train your cannon
  slop](https://github.com/Open-Science-Ledger/how-to-train-your-slop-cannon/blob/cf11d3bd6faed710fcae7905f872a63cfa34aa45/train_your_slop_cannon_v1.pdf) - A short guide to using LLMs in research, 2026 (D. Loader, J. Oppenheim, T. Osborne).

* [Blog by Sebastin Raschka](https://magazine.sebastianraschka.com/)
    - Build a Reasoning Model (From Scratch) 
    - Build a Large Language Model (From Scratch) 

* Also, [https://distil.pub](https://distill.pub/) for excellent explanations (by
  Chris Olah) !

\begin{center}
\huge Questions ?
\end{center}

# Open Models and Reality

* Olmo models. [Try online](https://playground.allenai.org/)

* SAIR open model (not yet released)

<!-- Science and AI Research (SAIR)  -->

* FirstProofs study (third batch)[^firstproof] 

* Checkout the FirstProofs github repo[^repo] for many research-level harness

[^firstproof]: Third Batch Benchmark report, First Proof  [link](https://1stproof.org/third-batch.html#results).
[^repo]: Batch 3 harness
    [link](https://github.com/1stproof/batch-3/tree/main/batch-3-submissions)

# On quantization

* Usually floating points are 32 bits (IEEE 754 standard)

* Trim the weight values to save memory

* Check out `unsloth` ! Have quantizations of many models and where the quality
  starts dipping

* Usually quality starts dipping below 8 bits[^quality]

[^quality]: "Reliability Scaling Laws for Quantized Large Language Models", TUM, 2026


# Acknowledgments

* Nix - Thanks Piyush !

* `llama.cpp` github coderepo

* MoE models - Praneeth, Shivasai (UG students, DS dept.)

* Hacker news

* Less wrong articles


# Explanation of the flake file

- Useful part is the flags 

``` nix
"-DGGML_RPC=ON -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS" ];

```

- Some options commented. Try adding/removing depending on your
  hardware

- To turn on, place it inside the quotes above; remove to turn-off

- **To rebuild**: Exit nix shell - `Ctrl+D`. Type `nix develop` to rebuild

- Build can be stopped any time with `Ctrl+C`

- Type `nix develop` to restart. Build will start where it was left

