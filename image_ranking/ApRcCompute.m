function APRC = ApRcCompute(dist_array)
    Count=size(dist_array,1);
    APRC=zeros(Count,2);
    APRC(1,1)=dist_array(1,2);
    APRC(1,2)=dist_array(1,2)/20;
    for i=2:Count
        APRC(i,1)=(APRC(i-1,1)*(i-1)+dist_array(i,2))/i;
        APRC(i,2)=APRC(i-1,2)+dist_array(i,2)/20;
    end
end