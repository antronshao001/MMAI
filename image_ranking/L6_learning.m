clear all;
path = '/Users/anthony/Desktop/Course/MMAI/hw02/images/';
train_list = dir(strcat(path,'raw'));
color_vect = 42;
grid_x = 3;
grid_y = 3;

for i=4:length(train_list)
    train_name{i-3}=train_list(i).name;
end

vector_array = zeros(color_vect*grid_x*grid_y,400); %an array to record similarity distance (2nd column is cat lable)
for i=1:length(train_name)
    
    %record each img vector    
    train_img = imread(strcat(path,'raw/',train_name{i}));
    imgsize(i,1)=size(train_img,1);
    imgsize(i,2)=size(train_img,2);
    vector_train = ColorVector(train_img,grid_x,grid_y);
    vector_array(:,i) = vector_train;
end

L6_Matrix = inv(cov(vector_array')); %cov(A) return covariant matrix with column=>varible row=>sample