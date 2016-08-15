clear all;
path = '/Users/anthony/Desktop/Course/MMAI/hw02/images/';
train_list = dir(strcat(path,'raw'));
test_list =  dir(strcat(path,'queries'));
grid_x=3; %regional FF2d x grid
grid_y=3; %regional FF2d y grid
layer=2; %phog layer
%load train(baseline) and test(query) name list
for i=4:length(train_list)
    train_name{i-3}=train_list(i).name;
end

for i=4:length(test_list)
    test_name{i-3}=test_list(i).name;
end


APRC = zeros(400,2,20); %an array to record AP and Recall
dist_array = zeros(400,2); %an array to record similarity distance (2nd column is cat lable)
postAPRC  = zeros(20,2,20); %for precision to reall map
MAP = zeros(20,1); %output all query AP
for i=1:length(test_name)
    %for each query, check AP and recall
    test_img = imread(strcat(path,'queries/',test_name{i}));
    
    %%%%%% change texture %%%%%%
    vector_test = FFTVector(test_img,grid_x,grid_y);
    %vector_test = anna_phog(test_img,10,360,layer,[1;size(test_img,1);1;size(test_img,2)]);
    %%%%%% change texture %%%%%%
    
    for j=1:length(train_name)
        %for each baseline image, check AP
        train_img = imread(strcat(path,'raw/',train_name{j}));
        
        %%%%%% change texture %%%%%%
        vector_train = FFTVector(train_img,grid_x,grid_y);
        %vector_train = anna_phog(train_img,10,360,layer,[1;size(train_img,1);1;size(train_img,2)]);
        %%%%%% change texture %%%%%%
        
        dist_array(j,1) = ColorSimilarity(vector_test,vector_train,'L1');
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