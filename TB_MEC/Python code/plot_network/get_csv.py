"""This python file reads csv files for siouxfalls
By Yaze Li, University of Arkansas 05/15/2023"""

from pathlib import Path
import csv

def get_csv(filename, columns):
    """This function reads the csv file with the given
    filename string and a list of colums, and returns
    to a dictionary."""

    data = {}

    path = Path(filename)
    lines = path.read_text().splitlines()

    reader = csv.reader(lines)
    header_row = next(reader)

    for idx in range(len(columns)):
        data[columns[idx]] = []

    for row in reader:
        for idx in range(len(columns)):
            try:
                data[columns[idx]].append(int(row[idx]))
            except ValueError:
                data[columns[idx]].append(row[idx])
    return data