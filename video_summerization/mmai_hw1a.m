clear all;

frame_Num=751;
thresh_SH = 300000; %single histogram treshold for cut
thresh_lh = 100000; %single histogram 1st threshold for fade
thresh_LH = 300000; %single histogram 2nd threshold for fade
thresh_RH = [2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2]; %reginal historgram treshold
thresh_PAN = [10,10];
thresh_ZOM = [2,6];
path='/Users/anthony/Desktop/Course/MMAI/hw01/02_frame/';

%read 1 next frame for difference calculation
frame_this = imread(strcat(path,num2str(1),'.jpg'));
for i = 1:frame_Num-1
    frame_next = imread(strcat(path,num2str(i+1),'.jpg'));
    
    %handle frame differences
    feature(1,i) = FrameFeature(frame_this,frame_next,1); %single Histogram in 64-bin
    feature(2:17,i) = FrameFeature(frame_this,frame_next,2); %4x4 regional Histogram in 64-bin
    %feature(18:19,i) = FrameFeature(frame_this,frame_next,3); %20x15 grid motion vector with block mean vector magnitude and vector magnitude mean
    
    disp(strcat(num2str(i),' itteration'));
    frame_this = frame_next;
end


shot_pivot_SH = find(double(feature(1,:)>=thresh_SH));
shot_pivot_lh = find(double(feature(1,:)>=thresh_lh));
shot_pivot_LH = FadeCheck(shot_pivot_lh,thresh_LH,frame_Num,path,0); %dissolve
%shot_pivot_MV = ; %zoom and pan

%merge shot pivot
shot_pivot = unique(cat(2,shot_pivot_SH,shot_pivot_LH));

%output shot frame (1/2 shot pivot this and next)
shot_start = [1 shot_pivot];
shot_end = [shot_pivot frame_Num];
shot = round((shot_start+shot_end)/2);

%output average frame = frame_number / shot_number
mean_frame_per_shot = frame_Num / (length(shot_pivot)+1);