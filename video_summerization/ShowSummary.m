function OutImage = ShowSummary(shot,list,inlist,list_height,block_w,path)
    shot_tail=length(shot);
    list_tail=length(list_height);
    
    %cat all shots
    OutImage=[];
    for list_head=1:list_tail
        RowImage = MergeInList(shot(inlist==list_head), list(inlist==list_head), list_height(list_head), block_w, path);
        %combine image Row by Row
        if(list_head == list_tail)
            OutImage = AttatchImage(1,OutImage,RowImage); %special handle last attachment
        else    
            OutImage = MergeImage(1,OutImage,RowImage);  %combine image by ordering and label
        end
        %%%%%% show row by row %%%%%%%
        imshow(OutImage);
        pause;
    end
    
end


function RowImage = MergeInList(shot, list, height, block_w, path)
    RowImage = [];
    shot_head=1;
    shot_tail=length(shot);
    w_left=block_w;

    %load shot
    for i=1:shot_tail
        image(:,:,:,i)=imread(strcat(path,num2str(shot(i)),'.jpg'));
    end
    
    while shot_head<=shot_tail %combine image until row end
       next=shot_head+1<=shot_tail;
       nnext=shot_head+2<=shot_tail;
       if(list(shot_head)==height)
           
           RowImage=MergeImage(2,RowImage,imresize(image(:,:,:,shot_head),0.2*height));
           w_left = w_left-height;
           shot_head = shot_head+1;
       elseif(list(shot_head)==1 && height==2 && next && list(shot_head+1)==1)
           tempImage=MergeImage(1,imresize(image(:,:,:,shot_head),0.2),imresize(image(:,:,:,shot_head+1),0.2));
           RowImage=MergeImage(2,RowImage,tempImage);
           w_left = w_left-1;
           shot_head=shot_head+2;
       elseif(list(shot_head)==1 && height==3 && next && nnext && list(shot_head+1)+list(shot_head+2)==2)
           tempImage=MergeImage(1,image(:,:,:,shot_head),image(:,:,:,shot_head+1));
           tempImage=MergeImage(1,tempImage,image(:,:,:,shot_head+2));
           RowImage=MergeImage(2,RowImage,imresize(tempImage,0.2));
           w_left = w_left-1;
           shot_head=shot_head+3;
       elseif(list(shot_head)==1 && height==3 && next && nnext && list(shot_head+1)+list(shot_head+2)==3)
           if(list(shot_head+1)==1)
               tempImage=MergeImage(2,image(:,:,:,shot_head),image(:,:,:,shot_head+1));
               tempImage=MergeImage(1,tempImage,imresize(image(:,:,:,shot_head+2),2));
           else
               tempImage=MergeImage(2,image(:,:,:,shot_head),image(:,:,:,shot_head+2));
               tempImage=MergeImage(1,tempImage,imresize(image(:,:,:,shot_head+1),2));
           end
           RowImage=MergeImage(2,RowImage,imresize(tempImage,0.2));
           w_left = w_left-2;
           shot_head=shot_head+3;
       elseif(list(shot_head)==2 && height==3 && next && nnext && list(shot_head+1)+list(shot_head+2)==2)
           tempImage=MergeImage(2,image(:,:,:,shot_head+1),image(:,:,:,shot_head+2));
           tempImage=MergeImage(1,imresize(image(:,:,:,shot_head),2),tempImage);
           RowImage=MergeImage(2,RowImage,imresize(tempImage,0.2));
           w_left = w_left-2;
           shot_head=shot_head+3;
       else
           tempImage=padarray(image(:,:,:,shot_head),[size(RowImage,1),size(image,2),size(image,3)]);
           RowImage=MergeImage(2,RowImage,tempImage);
           block_w = block_w-temp_arrange(i);
           i=i+1;
       end
       imshow(RowImage);
        pause;
       
    end
    if(w_left~=0)
        disp('error');
    end
end


function image = MergeImage(dir,image_a,image_b) %combine image with truncate image fitting size
y=min(size(image_a,1),size(image_b,1));
x=min(size(image_a,2),size(image_b,2));
if(isempty(image_a))
    image = image_b;
elseif(dir==1)
    image_a = image_a(:,1:x,:);
    image_b = image_b(:,1:x,:);
    image = cat(dir,image_a,image_b);
else
    image_a = image_a(1:y,:,:);
    image_b = image_b(1:y,:,:);
    image = cat(dir,image_a,image_b);
end
end

function image = AttatchImage(dir,image_a,image_b) %combine image with padding image fitting size
y=max(size(image_a,1),size(image_b,1));
x=max(size(image_a,2),size(image_b,2));
if(isempty(image_a))
    image = image_b;
elseif(dir==1)
    if(x>size(image_b,2))
        pad_b = zeros(size(image_b,1),x-size(image_b,2),size(image_b,3));
        image_b = cat(2,image_b,pad_b);
    elseif(x>size(image_a,2))
        pad_a = zeros(size(image_a,1),x-size(image_a,2),size(image_a,3));
        image_a = cat(2,image_a,pad_a);
    end
else
    if(y>size(image_b,1))
        pad_b = zeros(y-size(image_b,1),size(image_b,2),size(image_b,3));
        image_b = cat(1,image_b,pad_b);
    elseif(y>size(image_a,1))
        pad_a = zeros(y-size(image_a,1),size(image_a,2),size(image_a,3));
        image_a = cat(1,image_a,pad_a);
    end
end
image = cat(dir,image_a,image_b);

end