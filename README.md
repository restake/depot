# depot
[![Automated Builder](https://github.com/restake/depot/actions/workflows/build.yml/badge.svg)](https://github.com/restake/depot/actions/workflows/build.yml)

Standardized way for building and distributing blockchain protocol binaries and Docker images.

## Features

In its current form, Depot takes care of the following tasks:

- Automatically building new binaries (when enabled)
- Applying Git patches when necessary
- Optionally building and publishing production-grade Docker images which utilize our custom base image

> [!NOTE]
> Builds are triggered automatically for a specific set of projects by an internal webhook service. For others, builds will be triggered manually.

## Usage

We currently build binaries and Docker images for the `x86_64` architecture. Built binaries are uploaded to our Cloudflare-hosted R2 bucket (EU West) and Docker images are pushed to Github Container Registry.

We may periodically clear out old binaries to free up bucket storage space and keep only the latest builds.

Supported projects are defined in [`config.yml`](https://github.com/restake/depot/blob/master/config.yml).

### Binaries

All binaries are publicly accessible via https://depot.restake.cloud.

Every uploaded binary will follow a specific URI schema: `https://depot.r2.restake.cloud/<node|tool>/<project>/<tag>/<binary>`.

### Docker Images

Built Docker images are published to our Github Contrainer Registry. See the full list [here](https://github.com/orgs/restake/packages?repo_name=depot).

## Contributing

If you find an issue or want to add a new project to our builder configuration, feel free to open a pull request.

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.

## License

MIT
