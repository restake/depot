# Depot

## Utilty for builidng and shipping blockchain binaries

Depot is an automated GitHub Actions workflow that simplifies the process of building and distributing binaries for various protocols.

**Disclaimer: This project is under active development.**

## Supported Protocols

- Jito-Solana
- Centauri
- Haqq
- Sui

_This list is not final, as we are constantly working on adding support for additional protocols._

## Design and Features

Depot automates the following key tasks:

- Fetching information upon a new release from newreleases.io
- Building binaries for specified protocols
- Applying patches if necessary
- Uploading built binaries to an R2 bucket
- Notifying on Slack when a new binary is built

**Built binaries can be found:** https://depot.r2.restake.cloud/node/{protocolname}/{version}/{binaryname}

## Contributing

If you find an issue or want to suggest improvements, feel free to open a pull request.

## License

MIT
