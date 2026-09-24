{
  description = "God-tier offline coding and solver environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bend.url = "github:lukasl-dev/bend.nix";
  };

  outputs = { self, nixpkgs, bend }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = false;
      };
      lib = pkgs.lib;

      pick = names:
        builtins.filter (x: x != null)
          (map (name: if builtins.hasAttr name pkgs then builtins.getAttr name pkgs else null) names);

      py = pkgs.python3.withPackages (ps:
        let
          pickPy = names:
            builtins.filter (x: x != null)
              (map (name: if builtins.hasAttr name ps then builtins.getAttr name ps else null) names);
        in pickPy [
          "numpy" "scipy" "sympy" "pandas" "polars" "pyarrow" "duckdb"
          "matplotlib" "plotly" "networkx" "scikit-learn" "statsmodels"
          "numba" "mpmath" "pillow" "opencv4"
          "requests" "httpx" "aiohttp" "beautifulsoup4" "lxml"
          "pydantic" "pytest" "hypothesis" "rich" "typer" "click"
          "jupyter" "ipython" "notebook"
          "openpyxl" "python-docx" "pypdf" "pdfplumber"
          "sqlalchemy" "psycopg" "pymongo" "redis"
          "z3-solver" "cvxpy" "pyomo" "pulp"
          "torch" "transformers" "datasets"
        ]);

      coreNames = [
        "bash" "zsh" "fish" "nushell" "coreutils" "findutils" "diffutils"
        "gnugrep" "gnused" "gawk" "gnutar" "gzip" "bzip2" "xz" "zstd"
        "zip" "unzip" "p7zip" "which" "file" "tree" "less" "tmux"
        "git" "git-lfs" "gh" "curl" "wget" "aria2" "rsync" "rclone"
        "jq" "yq-go" "ripgrep" "fd" "fzf" "bat" "eza" "delta"
        "parallel" "hyperfine" "just" "watchexec" "entr"
        "strace" "ltrace" "lsof" "procps" "psmisc" "util-linux"
      ];

      languageNames = [
        "gcc" "clang" "llvm" "lld" "lldb" "gdb" "valgrind"
        "cmake" "ninja" "meson" "gnumake" "pkg-config" "autoconf" "automake" "libtool"
        "go" "rustc" "cargo" "rustfmt" "clippy"
        "nodejs" "bun" "deno" "pnpm" "yarn"
        "jdk" "maven" "gradle"
        "ruby" "php" "lua" "luajit" "perl"
        "dotnet-sdk" "mono"
        "ghc" "cabal-install" "stack"
        "ocaml" "opam"
        "julia"
        "R"
        "zig"
        "nim"
        "crystal"
        "elixir" "erlang"
      ];

      solverNames = [
        "z3" "cvc5" "boolector" "bitwuzla"
        "minisat" "kissat" "cadical" "cryptominisat"
        "minizinc" "gecode"
        "highs" "glpk" "cbc" "clp" "scip"
        "maxima" "singular" "pari" "gap"
        "lean4" "coq" "isabelle"
        "alloy" "spin"
      ];

      scienceNames = [
        "gmp" "mpfr" "mpc" "boost" "eigen" "openblas" "lapack"
        "fftw" "gsl" "suitesparse"
        "graphviz" "gnuplot"
        "octave"
        "pandoc"
      ];

      dataNames = [
        "sqlite" "postgresql" "mariadb" "redis" "duckdb"
        "mongosh"
        "clickhouse"
        "jq"
      ];

      webNames = [
        "chromium" "firefox"
        "playwright-driver"
        "nodePackages.typescript" "nodePackages.eslint" "nodePackages.prettier"
      ];

      mediaNames = [
        "ffmpeg" "imagemagick" "graphicsmagick"
        "ghostscript" "poppler-utils" "qpdf" "pdftk"
        "pandoc" "texliveSmall"
        "sox" "lame"
        "tesseract"
      ];

      secNames = [
        "nmap" "masscan" "tcpdump" "wireshark-cli" "netcat-gnu" "socat"
        "openssl" "gnutls"
        "binutils" "patchelf" "elfutils"
        "radare2" "ghidra" "binwalk"
        "yara" "clamav"
        "shellcheck" "shfmt"
        "gitleaks" "trivy" "semgrep"
        "syft" "grype"
      ];

      devopsNames = [
        "docker-client" "docker-compose"
        "podman" "buildah" "skopeo"
        "kubectl" "kubernetes-helm" "kustomize"
        "terraform" "opentofu" "ansible"
        "awscli2" "azure-cli" "google-cloud-sdk"
        "vault" "consul"
        "nix" "nixfmt-rfc-style"
      ];

      bendPkg = bend.packages.${system}.bend;

      mkPack = name: paths: pkgs.buildEnv {
        inherit name;
        paths = paths;
        pathsToLink = [ "/bin" "/lib" "/share" "/include" ];
        ignoreCollisions = true;
      };

      core = mkPack "godpack-core" (pick coreNames ++ [ py ]);
      languages = mkPack "godpack-languages" (pick languageNames);
      solvers = mkPack "godpack-solvers" (pick solverNames);
      science = mkPack "godpack-science" (pick scienceNames ++ [ py ]);
      data = mkPack "godpack-data" (pick dataNames);
      web = mkPack "godpack-web" (pick webNames);
      media = mkPack "godpack-media" (pick mediaNames);
      security = mkPack "godpack-security" (pick secNames);
      devops = mkPack "godpack-devops" (pick devopsNames);
      godpack = mkPack "godpack" (
        [ core languages solvers science data web media security devops bendPkg ]
      );
    in {
      packages.${system} = {
        inherit core languages solvers science data web media security devops godpack;
        bend = bendPkg;
        default = godpack;
      };

      apps.${system}.bend = {
        type = "app";
        program = "${bendPkg}/bin/bend";
      };
    };
}
