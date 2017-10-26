'''
The aim of this script is to test the dataset module with SQLite
'''
import sqlite3
import dataset

# create db

db = dataset.connect('sqlite:///test_db.db')

table = db['sometable']
table.insert(dict(name='John Doe', age=37))
table.insert(dict(name='Jane Doe', age=34, gender='female'))

john = table.find_one(name='John Doe')
print(john)