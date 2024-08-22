# Get-ConfigFile.ps1

## Overview

`Get-ConfigFile` is a PowerShell function designed to download or copy a configuration file from a remote location. The function supports UNC paths and HTTP(S) URLs as sources, and it returns the file path location of the downloaded or copied configuration file.

## Features

- **Source Type Detection:** Automatically detects whether the source is a UNC path or an HTTP(S) URL.
- **Path Verification:** Verifies the accessibility of the download source before attempting to copy or download the file.
- **Verbose Output:** Provides detailed verbose output during the download/copy process to aid in troubleshooting.
- **Error Handling:** Robust error handling ensures that issues are caught and reported with clear messages.

## Supported Download Sources

- **UNC Paths:** e.g., `\\Server\Share\Config.json`
- **HTTP(S) URLs:** e.g., `https://example.com/config.json`

## Usage

### Syntax

```powershell
Get-ConfigFile.ps1 -DownloadSource <string> -Destination <string> [-Verbose]

Parameters
-DownloadSource (string): Mandatory. The UNC path or HTTP(S) URL of the config file location. This should include the filename and extension.
-Destination (string): Mandatory. The local path where the config file will be stored. This should also include the filename and extension.
-Verbose (switch): Optional. Provides detailed output during the download/copy process.
```

### Example
```powershell
Get-ConfigFile.ps1 -DownloadSource "\\Server\Test\Config.json" -Destination "C:\temp\config.json" -Verbose
This command attempts to download or copy the config file from the specified UNC path to C:\temp\config.json, with verbose logging enabled.
```

## License
This script is released under the GPL-3.0 License.

## Contributions
Contributions are welcome! If you encounter any issues or have suggestions for improvements, feel free to submit a pull request or open an issue in the repository.
