{
  description = "llama.cpp with RPC support for CUDA";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux"; # Adjust to your system if needed
                             
    # Values are: "x86_64-linux"   (Intel/AMD # 64bit)
    #             "aarch64-linux"  (ARM based Raspberry PI 64bit)

    pkgs = import nixpkgs { inherit system; config.allowUnfree = true;};
    hf = pkgs.python313Packages.huggingface-hub;
    pi = pkgs.pi-coding-agent;
  in {
    # Takes care of installing everything needed for cuda
    packages.${system}.default = pkgs.llama-cpp.override {
      cudaSupport = true;
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [ 
        self.packages.${system}.default 
        hf
        pi
        ];
      shellHook = ''
          echo "=== Distributed GGML (llama.cpp) Environment ==="
          echo "Available binaries: llama-cli, llama-server, ggml-rpc-server"
          echo "Available hugging face: hf"
          echo "Available agents: pi"
          echo "================================================"
        '';

    };
  };
}
