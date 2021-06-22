im = imread('img02.png');
im1 = rgb2gray(im);
im1 = imresize(im1, [50 50]);
fi = fopen('data.txt', 'wt');
[m, n] =size(im1);
for i=1:1:m
    for j=1:1:n
        if j==n
            fprintf(fi, '%x\n', im1(i,j));
        else
            fprintf(fi, '%x\n', im1(i,j));
        end
    end
end
fclose(fi);

