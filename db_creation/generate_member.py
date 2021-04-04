from pathlib import Path
import requests

temp_folder_location = "./temp"
temp_folder = Path(temp_folder_location)

files_to_download = [
    'https://theunitedstates.io/congress-legislators/legislators-current.json'
]

if not temp_folder.exists():
    temp_folder.mkdir()

for url in files_to_download:
    with open(temp_folder / Path(url).name, 'w') as new_file:
        new_file.write(requests.get(url).text)

        new_file.close()

# TODO: parse the json into CSV