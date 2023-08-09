#!/bin/bash

# Author: Ameer Jamal 

# Print a welcome message
echo -e "\n"
echo " --------------------------------------------------------  "
echo "  ____________  ____________  ____________  ____________  "  
echo " /___________/\/___________/\/___________/\/___________/\ " 
echo " \___________\/\___________\/\___________\/\___________\/ "     
echo "   ┳┳┓          ┳┓         ┓         ┳┳   ┓       ┳  ┏    "
echo "   ┃┃┃┏┓┓┏┏┓┏┓  ┃┃┏┓┏┓┏┓┏┓┏┫┏┓┏┓┏┓┏  ┃┃┏┓┏┫┏┓╋┏┓  ┃┏┓╋┏┓  "
echo "   ┛ ┗┗┻┗┛┗ ┛┗  ┻┛┗ ┣┛┗ ┛┗┗┻┗ ┛┗┗┗┫  ┗┛┣┛┗┻┗┻┗┗   ┻┛┗┛┗┛  "                                             
echo "  ____________  ____________  ____________  ____________  "  
echo " /___________/\/___________/\/___________/\/___________/\ " 
echo " \___________\/\___________\/\___________\/\___________\/ "
echo -e "\n"    
echo " ------------------------------------------------------  "
echo -e "\n"

# Check if Python is installed
if command -v python3 &>/dev/null; then
    echo "Python 3 is installed"
    # Install required Python packages
    pip3 install -r requirements.txt
else
    echo "Python 3 is not installed"
    read -p "Would you like to install Python 3 using Homebrew? (y/n) " install_python

    if [ "$install_python" == "y" ]; then
        # Check if Homebrew is installed
        if command -v brew &>/dev/null; then
            echo "Installing Python 3 using Homebrew..."
            brew install python3
            echo "Python 3 has been installed. Setting up environment..."
            export PATH="/usr/local/bin:$PATH"
            pip3 install -r requirements.txt
        else
            echo "Homebrew is not installed. Please install Homebrew first!"
            echo "Exiting Program..."
            exit 1
        fi
    else
        echo "Please install Python3 first!"
        echo "Exiting Program..."
        exit 1
    fi
fi

echo -e "\n"
echo "-----------------------------------------"

# Prompt the user for the path to the Maven project
echo "Where is the Maven project you want to update? (Enter full directory)"
read project_path

# Extract the last part of the project path
dir_name=$(basename "$project_path")

echo -e "\n"

# Prompt the user for the output directory
echo -e "Where do you want to save the output files?
\n (Press Enter for Current Directory)"
read output_dir

# If the user didn't provide an output directory, use the current directory
if [ -z "$output_dir" ]
then
  output_dir=$(pwd)
fi

# Convert output directory to absolute path
output_dir=$(realpath "$output_dir")

# Ask the user if they want to recursively check for pom files
echo "Do you want to recursively check for pom files? (y/n)"
read recursive_check

# Change to the directory of the Maven project
cd "$project_path"

function process_maven_output() {
    local output_dir="$1"
    local pom_dir="$2"
    
    echo "- Analyzing Maven project in directory $pom_dir"

    # Run the Maven command and redirect its output to a file in the output directory
    (cd "$pom_dir" && mvn versions:display-dependency-updates) > "$output_dir/mvn_output.txt"
    echo "- Created mvn_output.txt in $output_dir"
    
    # Extract lines starting with [INFO] and containing '->'
    grep '^\[INFO\].*->' "$output_dir/mvn_output.txt" > "$output_dir/info_lines.txt"
    echo "- Created info_lines.txt in $output_dir"

    # Parse the file and create a CSV file with your desired columns
    echo "Library" > "$output_dir/dependenciesUpdateInfo.csv"
    cat "$output_dir/info_lines.txt" | sed -e 's/\(.*\)\.\.\..* \(\.*\) -> \(.*\)/\1,\2,\3/' >> "$output_dir/dependenciesUpdateInfo.csv"
    echo "- Converted info_lines.txt to dependenciesUpdateInfo.csv in $output_dir"


    # Process with Python to refine CSV and generate Excel file
    python3 << END

import pandas as pd

# Define function to remove '.' from start of string until a number starts
def clean_version(version):
    while len(version) > 0 and not version[0].isdigit():
        version = version[1:]
    return version

# Define function to extract library name, current version and upgrade version
def extract_info(row):
    try:
        parts = row['Library'].split('...')
        library = parts[0].replace('[INFO]   ', '').strip()
        versions = parts[-1].split('->')
        current_version = clean_version(versions[0].strip())
        upgrade_version = versions[1].strip()
        return library, current_version, upgrade_version
    except Exception:
        return None, None, None

# Load the CSV file
df = pd.read_csv('$output_dir/dependenciesUpdateInfo.csv')

# Apply function to each row and drop rows with missing data
df[['Library', 'Current Version', 'Upgraded Version']] = df.apply(extract_info, axis=1, result_type='expand')
df = df.dropna()

df = df.drop_duplicates() # Remove duplicate Dependencys


# Save the updated DataFrame
df.to_csv('$output_dir/dependenciesUpdateInfo.csv', index=False)
df.to_excel('$output_dir/dependenciesUpdateInfo.xlsx', index=False)
print("Excel and CSV Creation Complete in $output_dir ")
END
}

main_output_dir="$output_dir/${dir_name}"
mkdir -p "$main_output_dir"

if [ "$recursive_check" == "y" ]; then
    process_maven_output "$main_output_dir" "$project_path"

    # Find all pom.xml files within two levels and loop over them
    find . -maxdepth 3 -name "pom.xml" | while read -r pom_path; do
        pom_dir=$(dirname "$pom_path")
        # Skip processing the main directory again
        if [ "$pom_dir" = "." ]; then
            continue
        fi
        directory_name=${pom_dir//\//_} # Replace / with _ to make a valid directory name
        directory_name=${directory_name#._} # Remove starting ._
        project_output_dir="$output_dir/$directory_name"
        mkdir -p "$project_output_dir"
        process_maven_output "$project_output_dir" "$pom_dir"
    done

    # Ask the user if they want to open the main output directory
    read -p "Open main output directory? (y/n) " open_dir
    if [ "$open_dir" == "y" ]
    then
        open "$main_output_dir"
        echo "Directory Opened Successfully"
        echo "Exiting Program..."
        exit 1
    fi
else
    # Original functionality for a single pom.xml
    process_maven_output "$main_output_dir" "$project_path"

    # Ask the user if they want to open the CSV
    read -p "Open CSV? (y/n) " open_csv
    if [ "$open_csv" == "y" ]
    then
        open "$main_output_dir/dependenciesUpdateInfo.csv"
        echo "File Opened Successfully"
        echo "Exiting Program..."
        exit 1
    fi
fi

echo "Program Complete"
echo "Exiting Program..."
