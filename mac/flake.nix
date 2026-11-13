{
  description = "llama.cpp with RPC support";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
  let
    system = "aarch64-darwin"; # Adjust to your system if needed
    pkgs = import nixpkgs { inherit system; };
    hf = pkgs.python313Packages.huggingface-hub;
    vulkan = pkgs.vulkan-tools;
  in {
    packages.${system}.default = pkgs.llama-cpp-vulkan.overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or []) ++ [ "-DGGML_RPC=ON"  ];
    });

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [ 
        self.packages.${system}.default 
        hf
        vulkan ];
      shellHook = ''
          echo "=== Distributed GGML (llama.cpp) Environment ==="
          echo "Available binaries: llama-cli, llama-server, ggml-rpc-server"
          echo "Available hugging face: hf"
          echo "================================================"
        '';

    };
  };
}
