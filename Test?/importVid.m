% convert between video / image sequences: https://www.mathworks.com/help/matlab/examples/convert-between-image-sequences-and-video.html
% this file is used to import the video
vid = VideoReader('input5.mp4');
scale = 1/2;

i = 1;
while hasFrame(vid)
   im = readFrame(vid);
   im = imresize(im,scale);
   
   imname = strcat('imgs5/', int2str(i),'.png');
   imwrite(im, imname);
   i = i + 1;
end

