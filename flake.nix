{
  description =
    "Dev environment for the Glide browser TypeScript config: tsserver/intellisense, ESLint, and Prettier for glide.ts.";

  inputs = {
    # Uses the nixos-unstable channel. Pinned in flake.lock once evaluated.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Single-system: this config lives on one machine. To generalise, wrap the
      # devShells below in a helper over a list of systems (e.g. flake-utils).
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "glide-config";

        packages = [
          # node + npm — the ONE binary missing from this machine. Its absence is
          # what disables `typescript-tools.nvim` (the tsserver-backed engine that
          # provides autocomplete / intellisense / hover doc-hints for glide.ts).
          pkgs.nodejs_22

          # vscode-eslint-language-server — the ESLint LSP that the neovim config
          # (`servers = { eslint = {} }`) launches when the binary is on PATH.
          pkgs.vscode-langservers-extracted

          # prettierd — the formatter daemon driven by conform.nvim.
          pkgs.prettierd
        ];

        shellHook = ''
          # Resolve project-local CLIs (tsc, eslint, prettier) from the shell too.
          export PATH="$PWD/node_modules/.bin:$PATH"

          # Guarded install: (re)install JS dev deps only when the manifest is newer
          # than node_modules (or node_modules is missing). Keeps re-entry fast.
          if [ ! -d node_modules ] \
            || [ package.json -nt node_modules ] \
            || { [ -f package-lock.json ] && [ package-lock.json -nt node_modules ]; }; then
            echo "glide-config: installing JS dev dependencies via npm…"
            npm install --no-audit --no-fund --loglevel=error
          fi

          echo "glide-config devShell ready (node $(node --version))."
          echo "Tip: launch neovim from this shell so typescript-tools + eslint activate."
        '';
      };
    };
}
