'''
Creating index data from index lists provided by Edgar
'''

import os
import csv
import setting
from index_top_page_parse import get_actual_url

input_path = setting.Setting.crawler_index_file_path
output_path = setting.Setting.csv_path

def read_all():
    files = os.listdir(input_path)
    for file in files:
        analyze_and_output(input_path, file)

def analyze_and_output(path, filename):
    data = open(path + filename, 'r')
    data_lines = data.read().split('\n')
    mode_pass = True
    index_list = ['Company Name', 'Form Type', 'CIK', 'Date Filed', 'URL']
    indexes = {}
    for index in index_list:
        indexes[index] = [-1, -1]
    error_rows = []
    #f = open(output_path + filename.replace('txt', 'csv'), 'wb')
    #csvWriter = csv.writer(f)
    csv_rows = []
    for line in data_lines:
        if 'Company Name' in line and 'Description' not in line:
            mode_pass = False
            for i in range(len(index_list)):
                indexes[index_list[i]][0] = line.find(index_list[i])
            for i in range(len(index_list)):
                if i != len(index_list) - 1:
                    indexes[index_list[i]][1] = indexes[index_list[i + 1]][0] - 1
                else:
                    indexes[index_list[i]][1] = -1

        if mode_pass:
            continue
        else:
            if 'Company Name' in line and 'Description' not in line:
                pass
            else:
                form_type = line[indexes['Form Type'][0]: indexes['Form Type'][1] + 1]

                if '10-K' in form_type or '10-Q' in form_type:
                    csv_row = []
                    for i in range(len(index_list)):
                        if i != len(index_list) - 1:
                            csv_row.append(line[indexes[index_list[i]][0]: indexes[index_list[i]][1] + 1].strip())
                        else:
                            tmp_url = line[indexes[index_list[i]][0]: len(line)].strip() 
                            try: 
                                csv_row.append(get_actual_url(tmp_url))
                            except:
                                error_rows.append(csv_row)
                                continue
                    csv_rows.append(csv_row)

    f = open(output_path + filename.replace('txt', 'csv'), 'wb')
    csvWriter = csv.writer(f)
    csvWriter.writerows(csv_rows)
    f.close()

    f = open(output_path + filename.replace('.txt', '') + '_err' + '.csv', 'wb')
    csvWriter = csv.writer(f)
    csvWriter.writerows(error_rows)
    f.close()

if __name__ == "__main__":
    read_all()
