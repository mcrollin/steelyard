<div align="center">
  <img src="https://github.com/mcrollin/Steelyard/assets/7055162/89c5cd9f-fa24-4a4a-bcaa-a3f9d94f80e8" width="300" height="300">
</div>

# ⚖️ Steelyard

![macOS](https://img.shields.io/badge/macOS-Ventura%20or%20later-blue)
![Swift Version](https://img.shields.io/badge/swift-5.9-orange.svg)
![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-green)
![License](https://img.shields.io/github/license/mcrollin/Steelyard.svg)
![Release](https://img.shields.io/github/release/mcrollin/Steelyard.svg)
 
## Overview
Steelyard is a utility for generating graphs related to app size evolution.

---

## Installation

### Homebrew (Recommended)
To install Steelyard using Homebrew, run the following command:
```bash
brew install mcrollin/steelyard/steelyard
```

### Mint
To install using Mint, run:

```bash
mint install mcrollin/Steelyard
```

### Manual Installation
Alternatively, you can manually build the tool:

```bash
swift build -c release --disable-sandbox --product steelyard
````

Or run it:

```bash
swift run steelyard
```

---

## Prerequisites

To use Steelyard, you'll need to provide several details that are obtained via Apple's Developer Portal.

Follow the following steps to create an API key and retrieve the necessary information.

### Step 1: Create an API Key
1. Go to [App Store Connect > Users and Access > Keys section ](https://appstoreconnect.apple.com/access/api).
2. Click the + button to create a new key.
3. Give the key a name, and enable access to App Store Connect API.
4. Download the .p8 file that is generated.

_Note: Store this file in a secure place, as you won't be able to download it again._

### Step 2: Retrieve Key and Issuer IDs
1. The Key ID is visible in the portal where you download the key.
2. The Issuer ID is available in the App Store Connect dashboard, under the Users and Access section.

### Step 3: Locate Private Key Path
The Private Key Path is the location where you've stored the downloaded .p8 file.

### Step 4: Find Your App ID
The App ID can be found in the App Store Connect dashboard, under the My Apps section.

---

## Commands

### Generate a Graph

![graph](https://github.com/mcrollin/Steelyard/assets/7055162/01e41e6f-b328-4bc9-8179-98863f3f205d)

To generate a graph, you need to provide several arguments like `key-id`, `issuer-id`, `private-key-path`, and `app-id`. The command format is as follows:

```bash
USAGE: steelyard graph <key-id> <issuer-id> <private-key-path> <app-id> [--verbose] [--open-output] [--limit <limit>] [--reference-device-identifier <reference-device-identifier>]

ARGUMENTS:
  <key-id>                The key ID from the Apple Developer portal.
  <issuer-id>             The issuer ID from the App Store Connect organization.
  <private-key-path>      The path to the .p8 private key file.
  <app-id>                The App ID.

OPTIONS:
  -v, --verbose           Display all information messages.
  -o, --open-output       Open the result graphs.
  -l, --limit <limit>     The number of builds to process, between 0 and 200. (default: 30)
  --reference-device-identifier <reference-device-identifier>
                          The reference device to highlight in the charts. (default: iPhone12,1)
  -h, --help              Show help information.

```

For more information, run:

```bash
steelyard graph --help
```

---

## License
This project is licensed under the MIT License.
