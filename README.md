<div align="center">
  <img src="https://github.com/mcrollin/Steelyard/assets/7055162/89c5cd9f-fa24-4a4a-bcaa-a3f9d94f80e8" width="300" height="300">
</div>

# ⚖️ Steelyard

[![Build Status](https://github.com/mcrollin/Steelyard/actions/workflows/ci.yml/badge.svg)](https://github.com/mcrollin/Steelyard/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/release/mcrollin/Steelyard.svg)](https://github.com/mcrollin/Steelyard/releases)
![macOS](https://img.shields.io/badge/macOS-Ventura%20or%20later-blue)
[![Swift Version](https://img.shields.io/badge/swift-5.9-orange.svg)](https://www.swift.org/documentation/)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-green)](https://www.swift.org/package-manager/)
![License](https://img.shields.io/github/license/mcrollin/Steelyard.svg)

## Overview
With Steelyard, generate insightful App Size Graphs & JSON Metrics using App Store Connect API on Mac.

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
1. Go to [App Store Connect > Users and Access > Keys > App Store Connect API](https://appstoreconnect.apple.com/access/api).
2. Click the + button to create a new key.
3. Give the key a name, select `Developer` (or higher) access role and generate it.
4. Download the generated .p8 file.

_Note: Store this file in a secure place, as you won't be able to download it again._

### Step 2: Retrieve Key and Issuer IDs
1. In the list, find your key, hover over the Key ID and tap on the `Copy Key ID` button.
2. The Issuer ID with a `Copy` button is available right above the list of keys, under the Users and Access section.

### Step 3: Locate Private Key Path
The Private Key Path is the location where you've stored the downloaded .p8 file.

### Step 4: Find Your App ID
The App ID can be found in the [App Store Connect > Apps > General > App Information > General Information > Apple ID](https://appstoreconnect.apple.com/apps).

---

## Commands

For each command, you'll need to supply the following arguments: `key-id`, `issuer-id`, `private-key-path`, and `app-id`.

### 📉 Generate Size History Graph

Create a PNG image that displays historical size graphs for a specific app.

![app-size](https://github.com/mcrollin/Steelyard/assets/7055162/9c068878-923b-4a4a-b80a-ab9a04ffaf50)

The command format is as follows:

```bash
USAGE: steelyard graph [<options>] <key-id> <issuer-id> <private-key-path> <app-id>

ARGUMENTS:
  <key-id>                The key ID from the Apple Developer portal.
  <issuer-id>             The issuer ID from the App Store Connect organization.
  <private-key-path>      The path to the .p8 private key file.
  <app-id>                The App ID.

OPTIONS:
  -l, --limit <limit>     Specify the number of items to analyze. (default: 30)
        - For builds, the range is 1 to 200.
        - For versions, the range is 1 to 50.
  --by-version            Fetch sizes categorized by version, not build. Slower to retrieve.
  --download-size/--no-download-size
                          Include download sizes. (default: --download-size)
  --install-size/--no-install-size
                          Include install sizes. (default: --install-size)
  -o, --output <output>   Specify the destination path for the generated file.
  -v, --verbose           Display all information messages.
  --reference-device-identifier <reference-device-identifier>
                          The reference device to highlight in the charts. (default: iPhone12,1)
  -h, --help              Show help information.

```

### 💾 Export Detailed Size Metrics

Produces a JSON file with in-depth size metrics for a specific app with the following format:

```json
{
  "id": "123456789",
  "name": "ExampleApp",
  "sizes": {
    "download": {
      "5.3.0": {
        "iPhone11": 1200000,
        "iPhone12": 1300000
      },
      ...
    },
    "install": {
      "5.3.0": {
        "iPhone11": 2500000,
        "iPhone12": 2600000
      },
      ...
    }
  }
}

```

The command format is as follows:

```bash
USAGE: steelyard data <key-id> <issuer-id> <private-key-path> <app-id> [--limit <limit>] [--by-version] [--download-size] [--no-download-size] [--install-size] [--no-install-size] [--output <output>] [--verbose]

ARGUMENTS:
  <key-id>                The key ID from the Apple Developer portal.
  <issuer-id>             The issuer ID from the App Store Connect organization.
  <private-key-path>      The path to the .p8 private key file.
  <app-id>                The App ID.

OPTIONS:
  -l, --limit <limit>     Specify the number of items to analyze. (default: 30)
        - For builds, the range is 1 to 200.
        - For versions, the range is 1 to 50.
  --by-version            Fetch sizes categorized by version, not build. Slower to retrieve.
  --download-size/--no-download-size
                          Include download sizes. (default: --download-size)
  --install-size/--no-install-size
                          Include install sizes. (default: --install-size)
  -o, --output <output>   Specify the destination path for the generated file.
  -v, --verbose           Display all information messages.
  -h, --help              Show help information.
```

---

## License
This project is licensed under the MIT License.
