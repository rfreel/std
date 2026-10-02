# Web tool membership regression

Run `nix-instantiate --eval --strict tests/web-tools.nix --arg nixpkgs /path/to/nixpkgs`.

The check evaluates the actual web pack and requires TypeScript, ESLint and Prettier to be included. Against nixpkgs `4975466d324710c576dc11ad614684e6bd8cad8e`, the original dotted package names fail this assertion; the supported top-level names pass.

The PR workflow freezes that same nixpkgs revision and its unpacked SHA-256. This is a finite membership regression, not proof that every version of the floating production input works. It neither builds packages nor exercises the installed binaries. Full pack builds and the existing DevOps license-policy conflict remain separate checks.
