clear all;
addpath('/Users/anthony/Desktop/Course/MMAI/hw02/lmnn/lmnn3/'); %path for LMNN library (lmnnCG.m)
path = '/Users/anthony/Desktop/Course/MMAI/hw02/images/';
train_list = dir(strcat(path,'raw'));
test_list =  dir(strcat(path,'queries'));
color_vect = 42;
phog_vect = 210; % 50(layer=1), 210(layer=2), 850(layer=3)
grid_x = 2; %color grid number
grid_y = 2;
layer = 2; %phog layer number
kn = 14; % k nearest neighbor
%load train(baseline) and test(query) name list
for i=4:length(train_list)
    train_name{i-3}=train_list(i).name;
end

for i=4:length(test_list)
    test_name{i-3}=test_list(i).name;
end

vector_array = zeros(color_vect*grid_x*grid_y+phog_vect,400); %an array to record similarity distance (2nd column is cat lable)
label=zeros(400,1);%an array for trianing image labling
for i=1:length(train_name)
    
    %record each img vector    
    train_img = imread(strcat(path,'raw/',train_name{i}));
    imgsize(i,1)=size(train_img,1);
    imgsize(i,2)=size(train_img,2);
    vector_train_color = ColorVector(train_img,grid_x,grid_y);
    vector_train_phog = anna_phog(train_img,10,360,layer,[1;size(train_img,1);1;size(train_img,2)]);
    vector_array(:,i) = [vector_train_color';vector_train_phog];
    %LMNN learning
    label(i)=ceil(i/20);%make all label and sample  
end

LMNN_Similarity = lmnnCG(vector_array,label,kn);

APRC = zeros(400,2,20); %an array to record AP and Recall
dist_array = zeros(400,2); %an array to record similarity distance (2nd column is cat lable)
postAPRC  = zeros(20,2,20); %for precision to reall map
MAP = zeros(20,1); %output all query AP

for i=1:length(test_name)
    %for each query, check AP and recall
    test_img = imread(strcat(path,'queries/',test_name{i}));
    vector_test_color = ColorVector(test_img,grid_x,grid_y);
    vector_test_phog = anna_phog(test_img,10,360,layer,[1;size(test_img,1);1;size(test_img,2)]);
    vector_check = [vector_test_color';vector_test_phog];
    
    for j=1:length(train_name)
        %for each baseline image, check AP

        dist_array(j,1) = vector_check'*LMNN_Similarity*vector_array(:,j);
        if(ceil(j/20)==i)
            dist_array(j,2) = 1; %turn on same category flag
        else
            dist_array(j,2) = 0;
        end 
    end
    
    [array_temp,index_temp]=sort(dist_array(:,1));%sorting by image distance
    dist_ordered = dist_array(index_temp,:);%retrieve from the first match
    APRC(:,:,i) = ApRcCompute(dist_ordered);%compute each recall APRC(:,2,i) and precision APRC(:,1,i)
    start = find(APRC(:,2,i)>0,1);
    startCount = 2;
    postAPRC(1,:,i)=APRC(start,:,i);
    % retrieve when ever recall increase
    for t=start+1:400
        if(APRC(t,2,i)>APRC(t-1,2,i))
            postAPRC(startCount,:,i)=APRC(t,:,i);
            startCount=startCount+1;
        end
    end
    MAP(i) = mean(postAPRC(:,1,i)); %output all query AP
end

mean(MAP);