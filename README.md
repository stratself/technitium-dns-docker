# Technitium DNS Server - stratself's docker image

Technitium DNS Server using Alpine with the some tweaks:

- Alpine-based image with mimalloc - 158MB compared to original's 265MB
- Github Actions based, containerized build
- Self-contained dotnet
- Serve Stale Max Wait Time upper bound increased to 6400 miliseconds. Normally not needed, but I have a specific use case

Setup should be same as [typical Technitium](https://github.com/TechnitiumSoftware/DnsServer/blob/master/docker-compose.yml), please open issue if otherwise. Use at your own risk.

Images are tagged according to TDNS versions, with a `v` prefix (i.e. `v14.3.0`).

Links:

- Technitium on Alpine: https://github.com/TechnitiumSoftware/DnsServer/discussions/1650
- Serve Stale Max Wait Time questions and increase: https://github.com/TechnitiumSoftware/DnsServer/issues/1643