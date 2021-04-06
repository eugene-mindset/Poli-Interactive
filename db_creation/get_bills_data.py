import json
from pathlib import Path
import requests
import sqlite3
import xml.etree.ElementTree as ET
import zipfile
from tqdm import tqdm

# Download bill XML files
congresses = ["111", "112", "113", "114", "115",  "116", "117"]
bill_types = ["hr", "s", "hjres", "sjres"]
base_url = "https://www.govinfo.gov/bulkdata/BILLSTATUS/"

bill_dir = Path("Bills")
bill_dir.mkdir()

for congress in tqdm(congresses, colour='blue', desc='Downloading bill information'):
    congress_dir = bill_dir / Path(congress)
    congress_dir.mkdir()
    print(f"Downloading files for Congress {congress}")

    for bill_type in bill_types:
        zip_url = f"{base_url}{congress}/{bill_type}/BILLSTATUS-{congress}-{bill_type}.zip"
        zip_path = congress_dir / Path(f"BILLSTATUS-{congress}-{bill_type}.zip")
        r = requests.get(zip_url)
        with open(zip_path, 'wb') as f:
            f.write(r.content)
        print(f"Downloaded {zip_path.name}")

        extract_dir = congress_dir / Path(f"{congress}-{bill_type}")
        with zipfile.ZipFile(zip_path, 'r') as bills_zip:
            bills_zip.extractall(extract_dir)
        print(f"Extracted to {str(extract_dir)}")


# Parse XML and create SQLite tables
con = sqlite3.connect('congress_bills.db')
cur = con.cursor()
print('Connected to DB')

# Create tables
cur.execute('''CREATE TABLE IF NOT EXISTS Congress (
    congress TEXT NOT NULL,
    startDate TEXT NOT NULL,
    endDate TEXT NOT NULL,
    PRIMARY KEY (congress))''')
cur.execute('''CREATE TABLE IF NOT EXISTS Member (
    member_id TEXT NOT NULL,
    firstName TEXT NOT NULL,
    middleName TEXT,
    lastName TEXT NOT NULL,
    birthday TEXT NOT NULL,
    gender TEXT NOT NULL,
    PRIMARY KEY (member_id))''')
cur.execute('''CREATE TABLE IF NOT EXISTS Role (
    member_id TEXT NOT NULL,
    congress TEXT NOT NULL,
    chamber TEXT NOT NULL,
    party TEXT NOT NULL,
    state TEXT NOT NULL,
    district TEXT,
    PRIMARY KEY (member_id, congress),
    FOREIGN KEY (member_id)
        REFERENCES Member (member_id)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (congress)
        REFERENCES Congress (congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION)''')
cur.execute('''CREATE TABLE IF NOT EXISTS Area (
    area TEXT NOT NULL,
    PRIMARY KEY (area))''')
cur.execute('''CREATE TABLE IF NOT EXISTS Bill (
    bill_num TEXT NOT NULL,
    congress TEXT NOT NULL,
    title TEXT NOT NULL,
    date_intro TEXT NOT NULL,
    area TEXT NOT NULL,
    PRIMARY KEY (bill_num, congress),
    FOREIGN KEY (congress)
        REFERENCES Congress (congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (area)
        REFERENCES Area (area)
            ON DELETE CASCADE
            ON UPDATE NO ACTION)''')
cur.execute('''CREATE TABLE IF NOT EXISTS Subject (
    subject TEXT NOT NULL,
    PRIMARY KEY (subject))''')
cur.execute('''CREATE TABLE IF NOT EXISTS Bill_Subject (
    bill_num TEXT NOT NULL,
    congress TEXT NOT NULL,
    subject TEXT NOT NULL,
    PRIMARY KEY (subject, bill_num, congress),
    FOREIGN KEY (bill_num, congress)
        REFERENCES Bill (bill_num, congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (subject)
        REFERENCES Subject (subject)
            ON DELETE CASCADE
            ON UPDATE NO ACTION)''')
cur.execute('''CREATE TABLE IF NOT EXISTS Sponsor (
    member_id TEXT NOT NULL,
    bill_num TEXT NOT NULL,
    congress TEXT NOT NULL, 
    PRIMARY KEY (member_id, bill_num, congress),
    FOREIGN KEY (member_id)
        REFERENCES Member (member_id)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (bill_num, congress)
        REFERENCES Bill (bill_num, congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION)''')
cur.execute('''CREATE TABLE IF NOT EXISTS Cosponsor (
    member_id TEXT NOT NULL,
    bill_num TEXT NOT NULL,
    congress TEXT NOT NULL,
    PRIMARY KEY (member_id, bill_num, congress),
    FOREIGN KEY (member_id)
        REFERENCES Member (member_id)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (bill_num, congress)
        REFERENCES Bill (bill_num, congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION)''')
print('Tables created')
con.commit()

# Enter data into Congress table
congress_file = open('congress_terms.txt')
terms_dates = congress_file.readlines()
terms_dates = [tuple(i.strip().split(',')) for i in terms_dates]
cur.executemany('INSERT INTO Congress VALUES (?, ?, ?)', terms_dates)
congress_file.close()
print('Congress table filled')

# Enter data into Area table
area_file = open('policy_areas.txt')
area_data = [(x.strip(),) for x in area_file.readlines()]
cur.executemany('INSERT INTO Area VALUES (?)', area_data)
area_file.close()
print('Area table filled')

# Enter data into Subject table
subject_file = open('legislative_subjects.txt')
subject_data = [(x.strip(),) for x in subject_file.readlines()]
cur.executemany('INSERT INTO Subject VALUES (?)', subject_data)
subject_file.close()
print('Subject table filled')

# Enter data into Member table and Role table
for congress in congresses:
    for chamber in ['house', 'senate']:
        json_file = open(f'./congress_members/{congress}-{chamber}.json', 'r')
        json_data = json.load(json_file)
        members = json_data['results'][0]['members']
        for member in tqdm(members, desc=f'Congress: {congress} Chamber: {chamber}', colour='blue'):
            member_data = (member['id'], member['first_name'], member['middle_name'], member['last_name'], member['date_of_birth'], member['gender'])
            cur.execute('INSERT OR REPLACE INTO Member VALUES (?,?,?,?,?,?)', member_data)

            role_data = (member['id'], congress, chamber, member['party'], member['state'], (member['district'] if chamber == 'house' else None))
            cur.execute('INSERT OR REPLACE INTO Role VALUES (?,?,?,?,?,?)', role_data)
print('Member and Role table filled')

con.commit()

# Enter Bill data
# bill_errors = []
# bill_xmls = bill_dir.glob('**/*.xml')
# for bill_xml in bill_xmls:
#     print(f'Parsing {bill_xml.name}')
#     try:
#         xml_root = ET.parse(bill_xml).getroot()
#         bill_elem = xml_root.find('bill')
#     except:
#         print(f'Error getting to bill element of {bill_xml.name}')
#         bill_errors.append(str(bill_xml))
#         continue

    

con.commit()
con.close()
