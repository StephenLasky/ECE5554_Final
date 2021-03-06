startFrame = 2;
endFrame = 400;
 
numFrames = endFrame - startFrame + 1;
 
imHeight = 270;
imWidth = 480;
 
binImgThreshold = 0.35;
 
k = 5;
km_iters = 5;
 
% places all the images into a nice array
ims = cell(numFrames, 1);
i=1;
for f = startFrame:endFrame
    imName = strcat('imgs5/',int2str(f),'.png');
    ims{i} = im2double(imread(imName));
    i = i + 1;
end
 
% computes the difference between the background and foreground
newIms = cell(numFrames,1);
binIms = cell(numFrames,1);
bgim = ims{1};




% clusters = zeros(k,2);  % IMPORTANT: stored as Y = 1, X = 2
if k > 3
    cColor = zeros(k,3,'double');
    cColor(:,1) = randperm(1000, k)';
    cColor(:,2) = randperm(1000, k)';
    cColor(:,3) = randperm(1000, k)';
    cColor(:,:) = cColor(:,:) / 1000;
else
    cColor = zeros(5,3,'double');
    cColor(1,:) = [0 1 0];  % green
    cColor(2,:) = [0 0 1];  % blue
    cColor(3,:) = [1 1 0];  % yellow
end


clusters = -1;
oldClusters = -1;
centroids = -1;
variances = zeros(k,1);
distBetweenClusters = zeros(k,k);

% graph data here
varianceGraphInfo = zeros(numFrames,k);
centroidGraphInfo = zeros(numFrames,k);
closestCentroidGraphInfo = zeros(numFrames,k);

for i=1:numFrames
    % find difference between bg and fg, change to grayscale
    diff = abs(ims{i} - bgim);
    diff2 = (diff(:,:,1).^2+diff(:,:,2).^2+diff(:,:,3).^2).^(0.5);
    
    % convert to binary image
    bin = diff2 > binImgThreshold;
    bin = logical(bin);
    bin = imerode(bin,1);
    bin = imerode(bin, [1 1 1]);
    binIms{i} = bin;
    
    % BEGIN 'CLUSTERING'
    [binY, binX] = find(bin);
    binYX = horzcat(binY, binX);
    numPts = size(binX); numPts = numPts(1);
    
    if numPts > k
        oldClusters = clusters;
        oldCentroids = centroids;
        [clusters, centroids] = kmeans(binYX, k);
        
        % now re-assign clusters
        if oldClusters ~= -1
            centroid_d = pdist2(centroids,oldCentroids);
            [centroid_d2, min_idx] = min(centroid_d);
            
            if size(unique(min_idx),2) == k
                centroidsCopy = centroids;
                for c = 1:k
                    c2 = min_idx(c);
                    centroids(c,:) = centroidsCopy(c2,:);
                end
            end
        end
    end
    
    % reassign the cluster points as determined by min_idx
    if oldClusters ~= -1 & size(unique(min_idx),2) == k
        for pt = 1:numPts
            c = clusters(pt);
            c = find(min_idx==c,k);
            clusters(pt) = c;
        end
    end
    
    % compute the variance of each clusters
    if numPts > k
        for c = 1:k
            L = clusters == c;
            d = pdist2(binYX(L,:),centroids(c,:));
            variances(c) = var(d);
        end
        varianceGraphInfo(i,:) = variances';    % add to graph info for later
    else
        varianceGraphInfo(i,:) = 0;    % add to graph info for later
    end
    
    
    
    % compute the distances between cluster centers
    % TODO
    
    % collect some other graph data
    if numPts > k
        centroidGraphInfo(i,:) = (centroids(:,1).^2 + centroids(:,2).^2).^(0.5);
    else
        centroidGraphInfo(i,:) = -1;
    end
    
    % compute the closet centroid distance
    d = pdist2(centroids,centroids);
    d(d==0) = realmax('double');
    d = min(d);
    closestCentroidGraphInfo(i,:) = d';
    
   
    % END 'CLUSTERING'
    
    % convert binary image back to RGB
    diff = cat(3, bin, bin, bin);
    

	% concatenate into video sequence
    newIms{i} = horzcat( diff , ims{i} );
    
    % color the clusters
    if numPts > k
        for pt = 1:numPts
            c = clusters(pt);

            y = binY(pt);
            x = binX(pt);
            newIms{i}(y,x,:) = cColor(c,:);
        end

        % place red squares at cluster centers
        if numPts > k
            centroids = round(centroids);
            for c = 1:k
                % first do in background subtraction image
                y = centroids(c,1);
                x = centroids(c,2);
                yl = max(1,y-2); xl = max(1,x-2);
                yu = min(imHeight,y+2); xu = min(imWidth,x+2);
                newIms{i}(yl:yu,xl:xu,1) = 1;
                newIms{i}(yl:yu,xl:xu,2:3) = 0;

                % then do in regular image
                xl = xl + imWidth;
                xu = xu + imWidth;
                newIms{i}(yl:yu,xl:xu,1) = 1;
                newIms{i}(yl:yu,xl:xu,2:3) = 0;
            end
        end
    end
    
    % add frame number to video
    newIms{i} = insertText(newIms{i},[25 25],int2str(i));
    
%     % DEBUGGING
%     if i >= 20
%         figure(); imshow(newIms{i});
%         1+2;
%     end
    
    % add variance for cluster 1 to video
    
%     figure(); imshow(newIms{i});
%     centroids
%     oldCentroids
%     1+2;
   % update the background image
%    a = 1.5;
%    L = logical(ones(imHeight, imWidth));
%    xl = max(1,round(x-a*avg_d));
%    xu = min(imWidth,round(x+a*avg_d));
%    yl = max(1,round(y-a*avg_d));
%    yu = min(imHeight,round(y+a*avg_d));
%    L(yl:yu,xl:xu) = 0;
%    
%    bgim(L) = bgim(L) / 2 + ims{i}(L) / 2;
end

for i=1:numFrames
    newIms{i} = im2uint8(newIms{i});
end


saveVideo(newIms);

% ANALYSIS PART BELOW ...
% GRAPH EVERYTHING??
dSize = 12;
startF = 20;
endF = numFrames;


% plot the variance between clusters
figure
for c = 1:k
    title('Variance of Distance Within Clusters');
    xlabel('Frame #')
    ylabel('Variance')
    plot(startF:endF,varianceGraphInfo(startF:endF,c), dSize, cColor(c,:));
    if c ~= k
        hold on
    else
        hold off
    end
end

% plot the distance between centroids
figure
for c = 1:k
    title('Closest Cluster Distance');
    xlabel('Frame #')
    ylabel('Distance')
    plot(startF:endF,closestCentroidGraphInfo(startF:endF,c), dSize, cColor(c,:));
    if c ~= k
        hold on
    else
        hold off
    end
end


