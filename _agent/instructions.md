# MacWiggleBox Project Instructions

Whenever you make any changes or updates to the MacWiggleBox codebase, you MUST follow these post-update deployment steps:

1. **Build in Release mode**: Use the `scripts/package.sh` script to build the release binary and assemble the `.app` bundle.
2. **Deploy to Applications**: Move the resulting `MacWiggleBox.app` into the system `/Applications` folder.

## Deployment Command
Run the following command to automate this:
```bash
./scripts/package.sh && mv MacWiggleBox.app /Applications/MacWiggleBox.app
```
