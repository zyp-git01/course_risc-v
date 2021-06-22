import cv2 as cv


img = cv.imread("img02.png")

img_gray = cv.cvtColor(img,cv.COLOR_RGB2GRAY)

img_new = cv.resize(img_gray,(50,50))
size = img_new.shape
cv.imwrite("new_02.jpg",img_new)
with open ("data.txt","w") as f:
    count = 0
    for i in range(50):
        for j in range(50):
            
            if count % 4 == 0 and count != 0:
                f.write("\n")
                print(j)
            f.write((8-len(bin(img_new[i][j])[2:]))*"0"+bin(img_new[i][j])[2:])
            count += 1
            # f.write(bin(img_new[i][j])[2:]+"\n")

    f.close()












