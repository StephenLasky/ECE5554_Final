% startFrame = 12;
% endFrame = 350;
startFrame = 12;
endFrame = 350;

numFrames = endFrame - startFrame + 1;

imHeight = 240;
imWidth = 320;

binImgThreshold = 0.35;

% places all the images into a nice array
ims = cell(numFrames, 1);
i=1;
for f = startFrame:endFrame
    imName = strcat('imgs/',int2str(f),'.png');
    ims{i} = im2double(imread(imName));
    i = i + 1;
end

% computes the difference between the background and foreground
newIms = cell(numFrames,1);
binIms = cell(numFrames,1);
bgim = ims{1};
for i=1:numFrames
    % find difference between bg and fg, change to grayscale
    diff = abs(ims{i} - bgim);
    diff2 = (diff(:,:,1).^2+diff(:,:,2).^2+diff(:,:,3).^2).^(0.5);
    
    % convert to binary image
    bin = diff2 > binImgThreshold;
%     bin = im2double(bin);
    bin = logical(bin);
    binIms{i} = bin;
    
%     % BEGIN 'CLUSTERING'
    [binY, binX] = find(bin);
    numPts = size(binX); numPts = numPts(1);
    if numPts > 1
        x = mean(binX); 
        y = mean(binY); 
        d = ((binY-y).^2 + (binX-x).^2).^(0.5);
        

        avg_d = mean(d);
        std_d = d / avg_d;
        L = std_d < 3;

        binY = binY(L);
        binX = binX(L);

        x = mean(binX); 
        y = mean(binY); 
        d = ((binY-y).^2 + (binX-x).^2).^(0.5);
    end
%     % END 'CLUSTERING'
    
    % convert binary image back to RGB
    diff = cat(3, bin, bin, bin);
    

    
	% concatenate into video sequence
    newIms{i} = horzcat( diff , ims{i} );
    
    % apply red point to x,y
    if numPts > 1
        x = round(x);
        y = round(y);
        newIms{i}(y-2:y+2,x-2:x+2,1) = 1;
        newIms{i}(y-2:y+2,x-2:x+2,2:3) = 0;
        newIms{i}(y-2:y+2,x-2+imWidth:x+2+imWidth,1) = 1;
        newIms{i}(y-2:y+2,x-2+imWidth:x+2+imWidth,2:3) = 0;
    end
    
    
   % update the background image
   a = 1.5;
   L = logical(ones(imHeight, imWidth));
   xl = max(1,round(x-a*avg_d));
   xu = min(imWidth,round(x+a*avg_d));
   yl = max(1,round(y-a*avg_d));
   yu = min(imHeight,round(y+a*avg_d));
   L(yl:yu,xl:xu) = 0;
   
   bgim(L) = bgim(L) / 2 + ims{i}(L) / 2;
end

for i=1:numFrames
    newIms{i} = im2uint8(newIms{i});
end


saveVideo(newIms);

% ANALYSIS PART BELOW ...


xs = 275;
xe = 320;
ys = 66;
ye = 134;

% turn everything to double precision
for i=1:numFrames
    ims{i} = im2double(ims{i});
end


im = ims{i};
bgim = ims{1};
diff = abs(bgim-im);
diff2 = (diff(:,:,1).^2+diff(:,:,2).^2+diff(:,:,3).^2).^(0.5);
sbs = horzcat(bgim,im,diff);



figure(); imshow(sbs);





