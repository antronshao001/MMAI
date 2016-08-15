clear all;

frame_Num=751;
thresh_SH = 450000; %single histogram treshold for cut
thresh_lh = 100000; %single histogram 1st threshold for fade
thresh_LH = 450000; %single histogram 2nd threshold for fade
thresh_Diff = 200000; %single historgram treshold
thresh_Score = 2000; %reginal historgram treshold
block_w = 8;
block_h = 3;

path='/Users/anthony/Desktop/Course/MMAI/hw01/07_frame/';

%read all frame for clustering
for i = 1:frame_Num
    frame(:,:,:,i) = imread(strcat(path,num2str(i),'.jpg'));
end


%create a cluster list with 2d array. root is when a number is correlated
%to its order
clusterlist = linspace(1,frame_Num,frame_Num); 
iteration = 1; % if no change in a cluster scan then iteration = 0
while(iteration == 1)
    iteration = 0;
    
    for i=1:frame_Num-1
        %for each cluster do merge, if not cluster root then go to next
        if clusterlist(i) == i
            
            for j=i+1:frame_Num
                %only check cluster root
                if(clusterlist(j) == j)
                    frame_diff = FrameFeature(frame(:,:,:,i),frame(:,:,:,j),1); %single Histogram in 64-bin
                    
                    %merge cluster
                    if(frame_diff < thresh_Diff)
                        clusterlist(clusterlist == j) = i;
                        iteration = 1;
                    end
                end
           
            end
            
           
        end
        %disp(strcat(num2str(i),' merge check'));
    end
    disp('merge itteration'); %%%%%%%%%%%

end

cluster = histc(clusterlist,linspace(1,frame_Num,frame_Num));

%shot seperatio
frame_this = imread(strcat(path,num2str(1),'.jpg'));
for i = 1:frame_Num-1
    frame_next = imread(strcat(path,num2str(i+1),'.jpg'));
    
    %handle frame differences
    feature(1,i) = FrameFeature(frame_this,frame_next,1); %single Histogram in 64-bin
    feature(2:17,i) = FrameFeature(frame_this,frame_next,2); %4x4 regional Histogram in 64-bin
    %feature(18:19,i) = FrameFeature(frame_this,frame_next,3); %20x15 grid motion vector with block mean vector magnitude and vector magnitude mean
    
    disp(strcat(num2str(i),' itteration')); %%%%%%%%%%%%
    frame_this = frame_next;
end


shot_pivot_SH = find(double(feature(1,:)>=thresh_SH));
shot_pivot_lh = find(double(feature(1,:)>=thresh_lh));
shot_pivot_LH = FadeCheck(shot_pivot_lh,thresh_LH,frame_Num,path,0); %pan, dissolve, fade using continuous window
%shot_pivot_MV = ; %zoom and pan

%merge shot pivot
shot_pivot = unique(cat(2,shot_pivot_SH,shot_pivot_LH));

%output shot frame (1/2 shot pivot this and next)
shot_start = [1 shot_pivot];
shot_end = [shot_pivot frame_Num];
shot = round((shot_start+shot_end)/2);

%output average frame = frame_number / shot_number
mean_frame_per_shot = frame_Num / (length(shot_pivot)+1);

%shot frame weight calculation shot with cluster rarity
for i=1:length(shot)
    shot_weight(i) = (shot_end(i) - shot_start(i))*log(frame_Num/cluster(clusterlist(shot(i))));
end
%shot to 3 level size list : shot_label
%ordering and devide shot with numbers of label (1,2,3) to (40%, 30%, 30%)
%for linear importance level use: shot_label = ceil((shot_weight-min(shot_weight)+0.01)/(max(shot_weight)-min(shot_weight)+0.01)*3); 
shot_label(1:length(shot_weight)) = 1;
weight_order=sort(shot_weight);
shot_label(shot_weight > weight_order(ceil(length(shot_weight)*0.4))) = 2;
shot_label(shot_weight > weight_order(ceil(length(shot_weight)*0.7))) = 3;


%calculate row block score in differnt arrangement row block (fix row and colunm size)
inlist(1:length(shot)) = 0;
list_num=1;

while  inlist(end)==0
    score = 1000000; %init score
    list_head = find(~inlist,1);
    for h = 1:block_h
            [temp_score,temp_arrange] = SearchArrangement(shot_label,inlist,block_w,h);
            if temp_score < score
                score = temp_score; arrange = temp_arrange;
                list_height(max(inlist)+1) = h;
            end
    end
    list(list_head:list_head+length(arrange)-1) = arrange; %give the best fit size to each shot
    inlist(list_head:list_head+length(arrange)-1) = max(inlist)+1; %give the list line to each shot
    list_num = list_num+1;
    clear arrange
end

%output image
ShowSummary(shot,list,inlist,list_height,block_w,path);

