# std / godpack

Temporary GitHub build workspace for a broad offline AI coding environment.

This repo uses Nix to build reproducible x86_64-linux packs for:
- Bend
- core Unix/developer tools
- language toolchains
- SAT/SMT/optimization/theorem-proving solvers
- scientific Python and native math libraries
- databases
- browser/web tooling
- document/media utilities
- security/reverse-engineering tools
- DevOps/cloud tooling

Each GitHub Actions job exports the complete Nix closure as a compressed .nar.zst artifact so it can be transferred into an offline environment.
