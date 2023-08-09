# Maven Dependency Update Script

This script automates the process of checking Maven projects for dependency updates. It provides options to check a single project or recursively search through nested projects, generating CSV and Excel reports of the dependencies that need updates.
#### This script has been tested for MacOS Ventura Version 13.4.1 
## Prerequisites

- Python 3
- Maven
- Homebrew (for macOS users who might need to install Python 3)

## Installation

1. Clone this repository:
    ```
    git clone https://github.com/Ameer-Jamal/Maven-Dependency-Update-Script.git
    cd Maven-Dependency-Update-Script.git

2. Make the script executable:
    ```
    chmod +x UpdateMavenProject.sh
    ```    ```

3. Ensure you have Python 3 installed. If not, the script offers an option to install it using Homebrew (macOS).

4. Install the required Python packages:
    ```
    pip3 install -r requirements.txt
    ```
---
 # ./UpdateMavenProject.sh

## Usage

Run the script with:

Follow the on-screen prompts to specify the Maven project directory and choose whether to perform a recursive search.

Output files, including `mvn_output.txt`, `info_lines.txt`, `dependenciesUpdateInfo.csv`, and `dependenciesUpdateInfo.xlsx`, will be saved to the specified directory or the current directory by default.

## Contributing

If you'd like to contribute, please fork the repository and make changes as you'd like. Pull requests are warmly welcomed.

## Feedback

If you have any feedback or issues, please open a GitHub issue in this repository.

