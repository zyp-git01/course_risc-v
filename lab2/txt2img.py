import cv2 as cv
import numpy as np

img = []
def bin2dec(str_bin):
    num = 0
    for i in range(8):
        num += int(sts_bin[i]) * 2^(7-i)
    return num

with open("data.txt",'r') as f:
    count = 0
    for i in range(50):
        for j in range(50):
            new_num = 



