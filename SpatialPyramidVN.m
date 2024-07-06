function Pyramid_Vectors = SpatialPyramidVN(input_vector_images,input_features,Dictionary,Options)

    % This function computes spatial pyramid matching vectors for a set of images using a given 
    % dictionary of visual words. The spatial pyramid representation captures spatial information 
    % by partitioning the image into increasingly finer sub-regions and computing histograms of 
    % local features found inside each sub-region.
    %
    % INPUT:
    %   input_vector_images - A cell array where each cell contains an image represented as a matrix.
    %   input_features - A cell array where each cell contains the features of the corresponding image.
    %   Dictionary - A matrix where each row represents a visual word.
    %   Options - A structure containing the following optional parameters:
    %       Levels (default: 3) - Number of levels in the spatial pyramid.
    %
    % OUTPUT:
    %   Pyramid_Vectors - A matrix where each row represents the spatial pyramid matching vector 
    %                     for the corresponding image.
    %
    % The function performs the following steps:
    % 1. Initializes the parameters and preallocates the output matrix.
    % 2. Iterates over each image to compute its spatial pyramid representation:
    %    a. Divides the image into bins at the finest level.
    %    b. Computes histograms of features within each bin.
    %    c. Aggregates histograms at coarser levels by summing adjacent bins.
    % 3. Stacks and weights the histograms from all levels to form the final pyramid vector.
    % 4. Stores the pyramid vector for each image in the output matrix.

arguments

    input_vector_images            {mustBeNonempty}

    input_features                 {mustBeA(input_features,"cell")}


    Dictionary                     {mustBeUnderlyingType(Dictionary, ...
                                                         'single')}

    Options.Levels                 {mustBePositive,mustBeInteger,...
                                    mustBeInRange(Options.Levels,1,3)} = 3

end

binsHigh = 2^(Options.Levels-1);

pyramid_all = zeros(length(input_vector_images), ...
    size(Dictionary,1)*sum((2.^(0:(Options.Levels-1))).^2));

for f = 1:length(input_vector_images)
    
    img = input_vector_images{f};
    to_read = read(input_features{f});
    wid = to_read.wid;
    hgt = to_read.hgt;

    pyramid_cell = cell(Options.Levels,1);
    pyramid_cell{1} = zeros(binsHigh, binsHigh, size(Dictionary,1));
    
    for i=1:binsHigh
        for j=1:binsHigh

            % find the coordinates of the current bin
            x_lo = floor(wid/binsHigh * (i-1));
            x_hi = floor(wid/binsHigh * i);
            y_lo = floor(hgt/binsHigh * (j-1));
            y_hi = floor(hgt/binsHigh * j);
           
            img_patch = img( (to_read.x > x_lo) & (to_read.x <= x_hi) & ...
                             (to_read.y > y_lo) & (to_read.y <= y_hi));
            
            % make histogram of features in bin
            pyramid_cell{1}(i,j,:) = hist(img_patch,1:size(Dictionary,1))./length(img);
        end
    end

    %% Compute histograms at the coarser levels
    num_bins = binsHigh/2;
    for l = 2:Options.Levels
        pyramid_cell{l} = zeros(num_bins, num_bins, size(Dictionary,1));
        for i=1:num_bins
            for j=1:num_bins
                pyramid_cell{l}(i,j,:) = ...
                pyramid_cell{l-1}(2*i-1,2*j-1,:) + ...
                pyramid_cell{l-1}(2*i,2*j-1,:)   + ...
                pyramid_cell{l-1}(2*i-1,2*j,:)   + ...
                pyramid_cell{l-1}(2*i,2*j,:);
            end
        end
        num_bins = num_bins/2;
    end

    %% stack all the histograms with appropriate weights
    pyramid = [];
    
    % Weight the coarser levels
    for l = 1:Options.Levels-1
        pyramid = [pyramid pyramid_cell{l}(:)' .* 2^(-l)];
    end

    % Weight the finer levels
    pyramid = [pyramid pyramid_cell{Options.Levels}(:)'... 
        .* 2^(1-Options.Levels)];

    % At this point the vector of the image produced by the pyramid of the image in question is 
    % placed in the respective row  
    pyramid_all(f,:) = pyramid;


end

Pyramid_Vectors = pyramid_all;

end