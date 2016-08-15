function [score,arrange] = SearchArrangement(shot_label,inlist,block_w,block_h)
%search possible arrangement of each row and give a minimum score
%shot_label: shot list with importance level label
%inlist: a list that reocord each shot is in which image row, 0 means not
%assigned
%block_w, block_h: width and height of each row block

list_head = find(~inlist,1);
score = 100000; %init score and arrange
arrange = []; 

%check different number of images with different possible medium(2x2) and
%large(3x3) image block
%check i pictures included in this block to fill full block or max number in list
for i = 1:min(block_w*block_h,length(inlist)-list_head+1) 
    % consider only the max large and medium block that could be put in row
    large_max = floor(block_w/3)*floor(block_h/3);
    medium_max = floor(block_w/2)*floor(block_h/2);

    for ln = 0:large_max %large block number
        for mn = 0:medium_max %medium block number
           if(ln*8+mn*3+i <= block_w*block_h) % only check total block size smaller than area 
               
               clear temp_arrange
               temp_arrange(1:i) = 1;
               
               if(ln>0) %init temp_arrange with 3-block
                  temp_arrange(1:ln) = 3;
               end
               search_ln = 0; %flag for ending large block cycle
               
               while search_ln ==0 && i >= ln+mn

                   if(mn>0) %init 2-block
                       temp_arrange(find(temp_arrange==1,mn))=2;
                   end
                   search_mn = 0; %flag for ending medium block cycle
                      
                   while search_mn ==0 && i>=ln+mn
                       
                       if(CheckBlockValid(temp_arrange, block_w, block_h)==1)
                           [score,arrange]=CheckMinScore(score,arrange,temp_arrange,shot_label,list_head,block_w,block_h,i,ln,mn);
                       end
                       
                       [temp_arrange,search_mn] = MoveArrange(temp_arrange,mn,2,search_mn); %move last 2-block
                   end

                   temp_arrange(temp_arrange==2)=1; %remove 2 block for next cycle
                   [temp_arrange,search_ln] = MoveArrange(temp_arrange,ln,3,search_ln);
                   
               end
               
             
              
               
           end
        end
    end



end

end

%function that push medium or large image block to next arrangement
function [arrange,search] = MoveArrange(arrange,move_order,block,search)
   list_occupy=find(arrange==block);
   list_vacant=find(arrange==1);
   if(isempty(list_occupy) || isempty(list_vacant)) %no block or space to move
       search = 1;
   elseif(list_occupy(move_order)<list_vacant(end)) %move to next open space
       exchange = list_vacant(find(list_vacant > list_occupy(move_order),1));
       arrange(exchange) = block;
       arrange(list_occupy(move_order)) = 1;
   elseif(move_order>1) %move previous block
       [arrange,search] = MoveArrange(arrange,move_order-1,block,search);
   else %no open space and first 
       search = 1;
   end
   
end

%check temp_arrange is whether with a minimum score
function [score, arrange] = CheckMinScore(score, arrange, temp_arrange, shot_label, list_head, block_w, block_h, block_num, large_num, medium_num)
    temp_score = sum((shot_label(list_head:list_head+length(temp_arrange)-1)-temp_arrange).^4)+(block_w*block_h-(large_num*8+medium_num*3+block_num))*10;
    if(temp_score<score) %assign score and arrange with the minimum
        arrange = temp_arrange;
        score = temp_score;
    end
end

%check if arrangement is valid to fill the row block
function valid = CheckBlockValid(temp_arrange, block_w, block_h)
    i=1;
    tail=length(temp_arrange);
    while i<=tail
       ip=i+1<=tail;
       ipp=i+2<=tail;
       if(temp_arrange(i)>block_h)
           valid =0;
           return    
       elseif(temp_arrange(i)==1 && block_h==2 && ip && temp_arrange(i+1)==1)
           block_w = block_w-1;
           i=i+2;
       elseif(temp_arrange(i)==1 && block_h==3 && ip && ipp && temp_arrange(i+1)+temp_arrange(i+2)==2)
           block_w = block_w-1;
           i=i+3;
       elseif(temp_arrange(i)==1 && block_h==3 && ip && ipp && temp_arrange(i+1)+temp_arrange(i+2)==3)
           block_w = block_w-2;
           i=i+3;
       elseif(temp_arrange(i)==2 && block_h==3 && ip && ipp && temp_arrange(i+1)+temp_arrange(i+2)==2)
           block_w = block_w-2;
           i=i+3;
       else
           block_w = block_w-temp_arrange(i);
           i=i+1;
       end
    end
    
    if(block_w>=0)
        valid=1;
    else
        valid=0;
    end
    
end
