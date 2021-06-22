fi = fopen('data.txt', 'r');
tx = fscanf(fi, '%d');
fclose(fi);
im2 = zeros(50,50);
for i=1:50
    for j=1:50
            im2(i,j) = tx((i-1)*50+j);
    end
end
imshow(im2,[]);
