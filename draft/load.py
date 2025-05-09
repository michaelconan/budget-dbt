import os
import csv
import sqlite3

DATA = {
    "raw_revolut__personal": "/revolut/personal",
    "raw_revolut__joint": "/revolut/joint",
    "raw_bofa__activity": "/bofa",
}

def load_data():

    # connect to database
    con = sqlite3.connect("db/etl.db")
    cur = con.cursor()

    # read data file for each table
    for table, path in DATA.items():
        # get files from data folder
        data_path = "data" + path
        data_files = os.listdir(data_path)
        for file in data_files:
            file_data = list()
            # read csv file to gather row data
            with open(os.path.join(data_path, file), "r") as fp:
                reader = csv.reader(fp.readlines())
                # collect row data from csv reader
                for row in reader:
                    file_data.append(row)
            
            # insert data into sqlite table
            cur.executemany(
                f"""INSERT INTO {table} 
                VALUES 
                ({",".join("?" for _ in range(len(file_data[0])))})""",
                file_data[1:],
            )
            
    con.commit()
    cur.close()
    con.close()

if __name__ == "__main__":
    load_data()