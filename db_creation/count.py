from pathlib import Path
import xml.etree.ElementTree as ET

bill_dir = Path("Bills")

total = 0
has_votes = 0
enacted = 0
vetoed = 0

voted_on = []
bill_xmls = bill_dir.glob('11[56]/**/*.xml')
for bill_xml in bill_xmls:
    total += 1
    bill_elem = ET.parse(bill_xml).getroot().find('bill')

    if len(bill_elem.find('recordedVotes')) > 0:
        has_votes += 1
        voted_on.append(bill_xml.name)

    bill_actions = bill_elem.find('actions')
    codes = [e.findtext('actionCode') for e in bill_actions]
    if '36000' in codes or '41000' in codes:
        enacted += 1
    if '31000' in codes:
        vetoed += 1


print(f'Total: {total}, Has Votes: {has_votes}, Enacted: {enacted}, Vetoed: {vetoed}')