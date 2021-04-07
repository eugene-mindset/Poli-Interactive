from datetime import datetime
from pathlib import Path
import requests
from selenium import webdriver
import sqlite3
import xml.etree.ElementTree as ET


browser = webdriver.Chrome()

my_headers = {'x-api-key': 'P7k16Zc4DQelqwjQZ7dJmfoEyJjVDINlKsxEwg3t'}

con = sqlite3.connect('congress_bills.db')
cur = con.cursor()
print('Connected to DB')

cur.execute('''DROP TABLE IF EXISTS Vote''')
cur.execute('''CREATE TABLE IF NOT EXISTS Vote (
    member_id TEXT NOT NULL,
    bill_num TEXT NOT NULL,
    congress TEXT NOT NULL,
    position TEXT NOT NULL,
    PRIMARY KEY (member_id, bill_num, congress),
    FOREIGN KEY (member_id)
        REFERENCES Member (member_id)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (bill_num, congress)
        REFERENCES Bill (bill_num, congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION)''')
con.commit()
print('Vote table created')

# Get bill_num and congress
parse_failed = []
bill_dir = Path("Bills")
bill_xmls = bill_dir.glob('11[56]/**/*.xml')
for bill_xml in bill_xmls:
    try:
        start_time = datetime.now()

        xml_root = ET.parse(bill_xml).getroot()
        bill_elem = xml_root.find('bill')

        if len(bill_elem.find('recordedVotes')) < 1:
            continue

        bill_num = bill_elem.findtext('billType').lower() + bill_elem.findtext('billNumber')
        bill_congress = bill_elem.findtext('congress')

        # Use selenium to open govtrack url
        govtrack_url = f'https://www.govtrack.us/congress/bills/{bill_congress}/{bill_num}'
        browser.get(govtrack_url)

        # For both chambers, input session and roll call of vote I want, or no vote
        house_input = input('House vote? <session_num> <roll_call>, or n: ')
        senate_input = input('Senate vote? <session_num> <roll_call>, or n: ')

        # Call API to get data and insert into a Votes table
        try:
            h_sesh, h_roll = house_input.split()

            req_url = f'https://api.propublica.org/congress/v1/{bill_congress}/house/sessions/{h_sesh}/votes/{h_roll}.json'
            res = requests.get(req_url, headers=my_headers)
            if res.status_code != 200:
                print(f'Status code of {res.status_code} when doing {bill_xml.name} for house')
                parse_failed.append(bill_xml.name)
                continue
            vote_data = res.json()['results']['votes']['vote']['positions']
            for member in vote_data:
                to_insert = (member['member_id'], bill_num, bill_congress, member['vote_position'])
                cur.execute('INSERT INTO Vote VALUES (?,?,?,?)', to_insert)
        except:
            pass

        try:
            s_sesh, s_roll = senate_input.split()
            req_url = f'https://api.propublica.org/congress/v1/{bill_congress}/senate/sessions/{s_sesh}/votes/{s_roll}.json'
            res = requests.get(req_url, headers=my_headers)
            if res.status_code != 200:
                print(f'Status code of {res.status_code} when doing {bill_xml.name} for senate')
                parse_failed.append(bill_xml.name)
                continue
            vote_data = res.json()['results']['votes']['vote']['positions']
            for member in vote_data:
                to_insert = (member['member_id'], bill_num, bill_congress, member['vote_position'])
                cur.execute('INSERT INTO Vote VALUES (?,?,?,?)', to_insert)
        except:
            pass

        print(f'Took {(datetime.now() - start_time).seconds} seconds')
        print()
        con.commit()
    except:
        print(f'{bill_xml.name} failed')
        parse_failed.append(bill_xml.name)

with open('failed.txt', 'w') as f:
    f.writelines(parse_failed)

con.commit()
con.close()