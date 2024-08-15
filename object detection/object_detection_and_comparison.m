clc; clear all;
tic
% read the image to be analysed
im = imread('mete_1.PNG');
I = rgb2gray(im);

% create the filter kernel
H = fspecial('gaussian',1,0.5); 

% blur the image
I = imfilter(I,H); 

% convert the image to black & white
masked_img = im2bw(I, 0.2);

% measure properties of detected regions
props = regionprops(masked_img, 'BoundingBox', 'Area', 'Eccentricity', 'Orientation', 'Perimeter', 'PixelIdxList');

% draw boxes on the regions and crop those boxes
figure;
imshow(im);
hold on;
features = [];
labels = {};
im_new_cell = cell(1,0);
imcell = cell(1,numel(props));
for k = 1:numel(props)
    % extract features
    area = props(k).Area;
    perimeter = props(k).Perimeter;
    bounding_box = props(k).BoundingBox;
    eccentricity = props(k).Eccentricity;
    
    % feature vector: [Area, Perimeter, BoundingBox dimensions, Eccentricity]
    feature_vector = [area, perimeter, bounding_box(3:4), eccentricity];
    features = [features; feature_vector];
    try 
        if bounding_box(3)>25 && bounding_box(4)>25 && bounding_box(3)<50 && bounding_box(4)<50
            % draw bounding boxes around detected regions
            rectangle('Position', props(k).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
            imcell{k} = imcrop(im,props(k).BoundingBox);
            im_new_cell{end+1}=imcell{k};
        end
    end
end

% images detected, now compare with template image.
% load the 2nd image
image2 = imread('cropping.PNG');
figure
imshow(image2)

% initialize result matrix then write mse and ssim values
result_matrix = zeros(2,length(im_new_cell));
for j = 1:length(im_new_cell)
    image1 = im_new_cell{j};
    if size(image1, 3) == 3
        image1 = rgb2gray(image1);
    end
    if size(image2, 3) == 3
        image2 = rgb2gray(image2);
    end
    
    % resize the image
    size_index = 7000;
    image1 = imresize(image1,[size_index size_index]);
    image2 = imresize(image2,[size_index size_index]);
    
    % ensure images are of the same size
    if size(image1) ~= size(image2)
        error('Images must be of the same size.');
    end
    
    % calculate mean squared error (mse)
    mse = mean((double(image1) - double(image2)).^2, 'all');
    
    % calculate structural similarity index (ssim)
    [ssimval, ssimmap] = ssim(image1, image2);

    result_matrix(1,j) = mse;
    result_matrix(2,j) = ssimval;
end

% find the max ssim value to indicate the most similar object
max_index = find(result_matrix(2,:) == max(result_matrix(2,:)));
figure;
imshow(im_new_cell{max_index})

% display the results
fprintf('Mean Squared Error (MSE): %.4f\n', result_matrix(1,max_index));
fprintf('Structural Similarity Index (SSIM): %.4f\n',  result_matrix(2,max_index));
toc