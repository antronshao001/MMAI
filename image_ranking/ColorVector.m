function vector = ColorVector(img,grid_x,grid_y)
%img(Y,X,RGB)    
size_x = size(img,2);
size_y = size(img,1);
region_x = round(size_x/grid_x); %region size
region_y = round(size_y/grid_y);

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
        %calculate region vector
        temp_vector = ColorBin(img(start_y:end_y,start_x:end_x,:));
        temp_vector = temp_vector/norm(temp_vector); %normalized by norm2
        vector_range=length(temp_vector);
        vector(((i-1)*grid_y+j-1)*vector_range+1:((i-1)*grid_y+j)*vector_range) = temp_vector;
        
    end
end

end

function binValue = ColorBin(img)
%define bin scope
hBinCount = 10; %hue bin count 0,1,2,...9
sBinCount = 3; %saturation bin count 0,1
vBinCount = 6; %value bin count **0=black 0,1,2,3
vBinGreyCount = 2; %grey bin count
hBinDef = linspace(0,1,hBinCount+1);
sBinDef = linspace(0,1,sBinCount+1);
vBinDef = linspace(0,1,vBinCount+1);

hsvimg = rgb2hsv(img);
hmap = floor(hsvimg(:,:,1)*hBinCount*0.999999); %to hue bin map
smap = floor(hsvimg(:,:,2)*sBinCount*0.999999); %to saturation bin map
vmap = floor(hsvimg(:,:,3)*vBinCount*0.999999); %to value bin map
hsvmap = hmap + smap*hBinCount + vmap*sBinCount*hBinCount;
greyRange = hBinCount*sBinCount*vBinGreyCount; % grey scale bin range
colorRange = hBinCount*sBinCount*vBinCount; %h * s * v bin range

binValue = histc(hsvmap,[linspace(0,greyRange,vBinGreyCount+1),linspace(greyRange+1,colorRange,hBinCount*sBinCount*(vBinCount-vBinGreyCount))]); % get bin hist
binValue = sum(binValue,2);
binValue(end) = [];

end
