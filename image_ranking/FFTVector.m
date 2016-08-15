function vector = FFTVector(img,grid_x,grid_y)
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
        temp_vector = FourierBin(img(start_y:end_y,start_x:end_x,:));
        %temp_vector = temp_vector/norm(temp_vector); %normalized by norm2
        vector_range=length(temp_vector);
        vector(((i-1)*grid_y+j-1)*vector_range+1:((i-1)*grid_y+j)*vector_range) = temp_vector;
        
    end
end

end

function binValue = FourierBin(img)
%define bin scope
xRange = size(img,2);
yRange = size(img,1);
rRange = sqrt(xRange^2+yRange^2)/2; %define radius range
rBinCount = 5; %radius bin count 0,1,2,...4
aBinCount = 8; %angle bin count 0,1,2,...7
rBinDef = linspace(0,rRange,rBinCount+1);
aBinDef = linspace(0,2*pi,aBinCount+1);
binValue = zeros(rBinCount*aBinCount,1); %histmap(r*aBinCount+a)
fftimg = abs(fft2(double(rgb2gray(img))/255));

for i=1:xRange
    for j=1:yRange
        [aValue,rValue] = cart2pol(i-xRange/2,j-yRange/2);
        while(aValue<0)
           aValue = aValue+2*pi; 
        end
        aValue = floor(sum(aBinDef<aValue)*0.9999);
        rValue = floor(sum(rBinDef<rValue)*0.9999);
        binValue(rValue*aBinCount+aValue+1) = binValue(rValue*aBinCount+aValue+1) + fftimg(j,i); %put fftimg(x,y) to correct bin
    end
end

end