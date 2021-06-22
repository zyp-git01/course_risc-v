import cv2 as cv
import numpy as np

img_array = []

def binary_to_dec(bin_str):
    for j in range(4):
        num = int(bin_str[j*2:j*2 + 2],16)
        print(bin_str[j*2:j*2 + 2])
        img_array.append(num)


with open ("mem_r.txt","r") as file :
    line = file.readlines()
    # print(line)
    for i in range(len(line)):
        print(line[i][:-1])
        binary_to_dec(line[i][:-1])
    file.close()

# print(img_array)
img_array = np.array(img_array).reshape((50,50))

print(img_array)

cv.imwrite("trans.jpg",img_array)


