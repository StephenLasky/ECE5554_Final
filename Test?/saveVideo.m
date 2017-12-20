function saveVideo( ims )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% create the video writer with 1 fps
 writerObj = VideoWriter('myVideo','MPEG-4');
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


end

