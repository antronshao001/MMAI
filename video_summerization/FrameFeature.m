%frame feature function
%type 1 for single histogram
%type 2 for 4x4 reginal histogram
%type 3 for motion vector 

function feature = FrameFeature(frame_this,frame_next,type)
    switch type
        case 1
            feature = Histogram(frame_this,frame_next);
        case 2
            feature = RegionHistogram(frame_this,frame_next,4,4);
        case 3
            feature = MotionVector(frame_this,frame_next,20,15);
    end
            


end

function feature = Histogram(frame_this,frame_next)
    feature = sum(sum(abs(rgb2gray(frame_next) - rgb2gray(frame_this))/4));
end


function feature = RegionHistogram(frame_this,frame_next,grid_x,grid_y)
%frame(Y,X,RGB)    
size_x = size(frame_this,2); %frame size
size_y = size(frame_this,1);
region_x = size_x/grid_x; %region size
region_y = size_y/grid_y;

for i = 1:grid_x
    for j = 1:grid_y
        start_x = (i-1)*region_x+1;
        if(i*region_x < size_x)
            end_x = i*region_x; 
        else
            end_x = size_x;
        end
        start_y = (j-1)*region_y+1;
        if(j*region_y < size_y)
            end_y = j*region_y;
        else
            end_y = size_y;
        end
        
        feature((i-1)*grid_y+j) = sum(sum(abs(rgb2gray(frame_next(start_y:end_y,start_x:end_x,:)) - rgb2gray(frame_this(start_y:end_y,start_x:end_x,:)))/4));

    end
end
 
end

function feature = MotionVector(frame_this,frame_next,grid_x,grid_y)
%frame(Y,X,RGB)    
size_x = size(frame_this,2); %frame size
size_y = size(frame_this,1);
region_x = size_x/grid_x; %region size
region_y = size_y/grid_y;
window_x = 10;
window_y = 10;

for i = 1:grid_x
    for j = 1:grid_y
        start_x = (i-1)*region_x+1;
        if(i*region_x < size_x)
            end_x = i*region_x; 
        else
            end_x = size_x;
        end
        start_y = (j-1)*region_y+1;
        if(j*region_y < size_y)
            end_y = j*region_y;
        else
            end_y = size_y;
        end
        %check in window motion vector with smallest difference
        min_diff = WeightDiff(frame_this, frame_next, start_x, end_x, start_y, end_y, 0, 0,region_x,region_y);
        min_x = 0; min_y=0;
        for dir_x = -window_x:window_x
            for dir_y = -window_y:window_y
                
                frame_diff = WeightDiff(frame_this, frame_next, start_x, end_x, start_y, end_y, dir_x, dir_y,region_x,region_y);
                if(frame_diff < min_diff)
                    min_diff = frame_diff;
                    min_x = dir_x;
                    min_y = dir_y;
                end
                
            end
        end
        
        vector_x((i-1)*grid_y+j) = min_x;
        vector_y((i-1)*grid_y+j) = min_y;
        vector_len((i-1)*grid_y+j) = sqrt(min_x^2+min_y^2);
    end
end

feature(1) = sqrt(mean(vector_x)^2 + mean(vector_y)^2);
feature(2) = mean(vector_len);

end

function frame_diff = WeightDiff(frame_this, frame_next, start_x, end_x, start_y, end_y, dir_x, dir_y,region_x, region_y)
    size_x = size(frame_this,2); %frame size
    size_y = size(frame_this,1);
    padding = 20;
    start_x = Larger(start_x + padding, padding+1);    
    end_x = Smaller(end_x + padding, padding+1+size_x);
    start_y = Larger(start_y+padding, padding+1);
    end_y = Smaller(end_y+padding, padding+1+size_y);
    frame_this = rgb2gray(frame_this);
    frame_next = rgb2gray(frame_next);
    
    
    padding_this = zeros(size_y + 2*padding, size_x + 2*padding);
    padding_next = zeros(size_y + 2*padding, size_x + 2*padding);
    padding_this(padding+1:size_y+padding,padding+1:size_x+padding) = frame_this;
    padding_next(padding+1+dir_y:size_y+padding+dir_y,padding+1+dir_x:size_x+padding+dir_x) = frame_next;
    
    padding_diff = padding_next-padding_this;
    
    %return normalized vector frame difference
    frame_diff = sum(padding_diff(start_y:end_y,start_x:end_x))*(region_x*region_y)/((end_x-start_x)*(end_y-start_y));
    
    
end

function largerValue = Larger(value1,value2)
    if(value1<value2)
        largerValue = value2;
    else
        largerValue = value1;
    end
end

function smallerValue = Smaller(value1,value2)
    if(value1>value2)
        smallerValue = value2;
    else
        smallerValue = value1;
    end
end
