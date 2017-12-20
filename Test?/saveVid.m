startFrame = 12;
endFrame = 50;
numFrames = endFrame - startFrame + 1;

imHeight = 240;
imWidth = 320;


ims = cell(numFrames, 1);
i=1;
for f = startFrame:endFrame
    imName = strcat('imgs/',int2str(f),'.png');
    ims{i} = imread(imName);
    i = i + 1;
end

 % create the video writer with 1 fps
 writerObj = VideoWriter('myVideo.avi');
 writerObj.FrameRate = 30;
 
 % open the video writer
 open(writerObj);
 
 % write the frames to the video
 for u=1:length(ims)
     % convert the image to a frame
     frame = im2frame(ims{u});
     writeVideo(writerObj, frame);
 end
 
  % close the writer object
 close(writerObj);