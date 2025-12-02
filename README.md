# Downloads Organizer

A PowerShell script to automatically organize the `Downloads` folder by **file type** or **date**.

## Features
- Generates a report of current folder contents
- Suggests a target folder hierarchy
- Organizes files by:
  - **Type** (Documents, Images, Videos, Software, Compressed, Misc)
  - **Date** (Year-Month based folders)
- Creates missing folders only (does not overwrite existing ones)
- Moves files into the correct structure

## Usage

1. Clone the repository:
   ```powershell
   git clone https://github.com/<your-username>/DownloadsOrganizer.git
   cd DownloadsOrganizer/src