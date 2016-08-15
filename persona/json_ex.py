import json
import numpy as np
from pprint import pprint
n_img = 200
n_label_flag = 20
trait = ['Curious', 'Intellectual', 'Creative', 'Narrow Interest', 'Responsible', 'Organized', 'Neat', 'Hedonistic',
         'Outgoing', 'Withdrawn', 'Silent', 'unsocial', 'Cooperative', 'Modest', 'Irritable', 'Impolite',
         'Secure', 'Hardy', 'Unemotional', 'Nervous']

with open('label.json') as label_file:
    data = json.load(label_file)
# pprint(data)

# into dict{"tester":{img_num:{tag}}}
label_dict = {}
for name in data["results"]:
    label_dict[name["User"]] = {int(photo["photo"][:-4]): photo["tag"]
                                for photo in name["result"] if  photo["photo"].endswith(".jpg")}
# pprint(label_dict)

# into 3d numpy array [tester][img][label_flag]
label_array = np.zeros((len(label_dict), n_img, n_label_flag))
img_label_count = np.zeros(n_img)
name_count = 0
for name in label_dict:
    for img in label_dict[name]:
        img_label_count[img-1] += 1
        for flag in label_dict[name][img]:
            label_array[name_count][img-1][trait.index(flag)] = 1
    #next tester name
    name_count += 1
# print img_label_count
# print label_array
label_result = np.zeros((n_img, n_label_flag))
label_sum = np.sum(label_array, axis=0)
# print label_sum
for i in range(n_img):
    if img_label_count[i] == 0:
        label_result[i] = 0
    else:
        label_result[i] = label_sum[i] / img_label_count[i]
# print label_result

np.savetxt('label200', label_result, delimiter=',')