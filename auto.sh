#!/bin/bash

# ==========================================
# Script Name - auto.sh
# Description - Automatically fills the wget, dhcp, examname, examdate for linkpxe
# ==========================================

# Prompt zip file path
read -p "Enter the full path of the zip file: " zip_path

# Check if file exists
if [[ ! -f "$zip_path" ]]; then
	echo "Error: File not found!"
	exit 1
fi

# Extract folder name from zip file
filename=$(basename -- "$zip_path")
base_folder="${filename%.*}"

# Unzip the file
echo "Unzipping file...."
unzip "$zip_path" -d "$base_folder"

# Find the actual inner extracted folder (assumes only one subdirectory inside)
inner_folder=$(find "$base_folder" -type d -mindepth 1 -maxdepth 1)

# Ask for a new cver value to update
read -p "Enter the new cver value to update: " new_cver

# Update cver in opt/exam.conf and opt/examsetup.conf
for conf_file in "$inner_folder/opt/exam.conf" "$inner_folder/opt/examsetup.conf"; do
	if [[ -f "$conf_file" ]]; then
		echo "Updating cver in $conf_file..."
		sed -i "s/^cver=.*/cver=$new_cver/" "$conf_file"
	else
		echo "Warning: $conf_file not found!"
	fi
done

# Prompt for exam name and build date
read -p "Enter the new exam name: " new_exam
read -p "Enter the new build date (e.g., May 2025): " new_build_date

# Update line 7 in usr-bin/enablelogs
enablelogs_file="$inner_folder/usr-bin/enablelogs"

if [[ -f "$enablelogs_file" ]]; then
	echo "Updating line 7 in $enablelogs_file..."
	sed -i "7s|.*|echo -e \"\\n $new_exam Exam Linkpxe build date : $new_build_date - Production\"|" "$enablelogs_file"
else
	echo "Warning: $enablelogs_file not found!"
fi

echo "✅ All modifications completed successfully."

