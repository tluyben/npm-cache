# Local NPM Cache Registry

A local NPM registry system using Verdaccio for completely offline package management. This allows you to cache NPM packages locally and work without internet access or the global NPM registry.

## Directory Structure

```
./npm-cache/               # Project directory
  ├── serve                # Start the local registry server
  ├── add-npm              # Download and cache NPM packages
  ├── scan_projects        # Scan projects and cache their dependencies
  ├── add-package          # Add a local package to the cache
  ├── config.yaml          # Verdaccio configuration
  └── package.json         # Project dependencies

~/npm-cache/               # Storage directory (where packages are cached)
```

## Setup

1. Install dependencies (already done):
   ```bash
   cd ./npm-cache
   npm install
   ```

2. Ensure scripts are executable (already done):
   ```bash
   chmod +x serve add-npm scan_projects add-package
   ```

## Usage

### 1. Start the Local Registry Server

```bash
./npm-cache/serve
```

This will:
- Start Verdaccio on `http://localhost:4873`
- Store packages in `~/npm-cache`
- Display the web interface at `http://localhost:4873`

Leave this running in a terminal window.

### 2. Configure NPM to Use the Local Registry

In a new terminal, set your NPM registry:

**Option A: Environment variable (temporary)**
```bash
export NPM_CONFIG_REGISTRY=http://localhost:4873/
```

**Option B: NPM config (persistent)**
```bash
npm config set registry http://localhost:4873/
```

**Option C: Project-specific (.npmrc)**
Create a `.npmrc` file in your project:
```
registry=http://localhost:4873/
```

### 3. Cache Packages

#### Cache a specific package from NPM:
```bash
./npm-cache/add-npm <package-name>[@version]
```

Examples:
```bash
./npm-cache/add-npm express
./npm-cache/add-npm express@4.18.0
./npm-cache/add-npm @types/node
./npm-cache/add-npm @types/node@20.0.0
```

This will:
- Download the package from NPM
- Cache it in `~/npm-cache`
- Recursively cache all dependencies

#### Scan projects and cache all dependencies:
```bash
./npm-cache/scan_projects [directory]
```

Examples:
```bash
./npm-cache/scan_projects                    # Scan current directory
./npm-cache/scan_projects ~/Projects         # Scan specific directory
```

This will:
- Find all `package.json` files (excluding node_modules)
- Extract all dependencies
- Cache each unique package

#### Add a local package to the cache:
```bash
./npm-cache/add-package <path-to-package>
```

Examples:
```bash
./npm-cache/add-package ./my-local-package
./npm-cache/add-package ~/Projects/my-lib
```

This will:
- Pack the local package using `npm pack`
- Store it in the local cache
- Make it available for installation

### 4. Install Packages

Once the registry is running and configured, use npm normally:

```bash
npm install express
npm install
```

Packages will be fetched from your local cache instead of the global NPM registry.

## Configuration Details

### Verdaccio Configuration (config.yaml)

- **Storage**: `~/npm-cache` - All packages are stored here
- **Uplinks**: Empty (`{}`) - No upstream registries (fully offline)
- **Packages**:
  - `access: $all` - Anyone can read packages
  - `publish: $authenticated` - Only authenticated users can publish
  - `proxy: []` - No proxying to external registries
- **Server**: Listens on `http://0.0.0.0:4873`

### Environment Variables

```bash
# Set registry
export NPM_CONFIG_REGISTRY=http://localhost:4873/

# Alternative for yarn
export YARN_REGISTRY=http://localhost:4873/
```

### Reset to Global NPM Registry

```bash
# Using environment variable
unset NPM_CONFIG_REGISTRY

# Using npm config
npm config delete registry

# Or manually set to default
npm config set registry https://registry.npmjs.org/
```

## Workflow Examples

### Scenario 1: Offline Development Setup

```bash
# 1. Start the local registry
./npm-cache/serve &

# 2. Configure NPM
export NPM_CONFIG_REGISTRY=http://localhost:4873/

# 3. Scan and cache all dependencies from your projects
./npm-cache/scan_projects ~/Projects

# 4. Now you can work offline - all packages are cached
```

### Scenario 2: Adding New Packages

```bash
# Registry is running and configured

# Add a specific package
./npm-cache/add-npm lodash

# Now install it in your project
cd ~/Projects/my-app
npm install lodash
```

### Scenario 3: Development with Local Packages

```bash
# Add your local package to the cache
./npm-cache/add-package ~/Projects/my-library

# Install it in another project
cd ~/Projects/my-app
npm install my-library
```

## Troubleshooting

### Packages not found
- Ensure the registry server is running (`./npm-cache/serve`)
- Verify NPM is configured: `npm config get registry`
- Check if the package was cached: `ls ~/npm-cache`

### Registry connection refused
- Make sure `./npm-cache/serve` is running
- Check if port 4873 is available: `lsof -i :4873`

### Cannot publish
- First login: `npm adduser --registry http://localhost:4873`
- Create a user when prompted

### Clear cache and start fresh
```bash
# Stop the server (Ctrl+C)
rm -rf ~/npm-cache
# Restart the server
./npm-cache/serve
```

## Notes

- The `add-npm` script recursively downloads dependencies. This can take time for packages with many dependencies.
- Scoped packages (e.g., `@types/node`) are supported.
- The system is designed for offline use - set `uplinks: {}` ensures no external registry calls.
- For production use, consider using HTTPS and proper authentication.

## Limitations

- Version range resolution in `add-npm` is simplified (uses latest for dependencies)
- No automatic package updates - you must manually re-cache packages
- Authentication is basic (htpasswd file)
