function shot_pivot = FadeCheck(shot_pivot_LH,thresh_SH,frame_Num,path,pivot_window)
% shot_pivot_LH record the 1st fade shot pivot list
% thresh_SH is 2nd threshold
% pivot_window is a fix check differnce window, 0 means use continuous
% check
shot_pivot=[];
if nargin < 5
    pivot_window = 6; %default pivot check window
end
pivot_Num = 1; %fade check pivot

if(pivot_window ==0) %no pivot window use continuous check
    temp_pivot=[];
    check_s=shot_pivot_LH(1);
    check_num=1;
    
    while ~isempty(check_s)
        check_e=check_s+1;
    
        while check_e+1 == shot_pivot_LH(find(shot_pivot_LH==check_e,1))+1
            check_e = check_e+1;
        end
    
        frame_s = imread(strcat(path,num2str(check_s),'.jpg')); %load frame_this
        frame_e = imread(strcat(path,num2str(check_e),'.jpg'));
        
        if( FrameFeature(frame_s,frame_e,1) > thresh_SH )
            temp_pivot(check_num) = check_s;
            check_num=check_num+1;
        end
        check_s = shot_pivot_LH(find(shot_pivot_LH > check_e,1));
    end
    shot_pivot = temp_pivot;
else
for i = 1:length(shot_pivot_LH) %fix window check
    
    pivot_this = shot_pivot_LH(i);
    %keep check next frame if not over last frame
    if(pivot_this+1<frame_Num)
        
        frame_this = imread(strcat(path,num2str(pivot_this),'.jpg')); %load frame_this
        pivot_check = pivot_this+1;
        if(pivot_this + pivot_window < frame_Num)
            pivot_bound = pivot_this + pivot_window;
        else
            pivot_bound = frame_Num;
        end    
        
        while pivot_check < pivot_bound 
       
            frame_check = imread(strcat(path,num2str(pivot_check),'.jpg')); %load frame_check
            
            %if diff > thresh record pivot 
            if( FrameFeature(frame_this,frame_check,1) > thresh_SH )
                shot_pivot(pivot_Num) = shot_pivot_LH(i); %record shot_pivot with current pivot
                pivot_Num = pivot_Num+1; %update pivot number
                pivot_check = pivot_bound; %set to break while
            end
        
            pivot_check = pivot_check+1;
        end
        
    end
end
end

end