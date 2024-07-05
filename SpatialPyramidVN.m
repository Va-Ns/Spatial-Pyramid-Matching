function Pyramid_Vectors = SpatialPyramidVN(input_vector_images,input_features,Dictionary,Options)

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
    
    % Στάθμιση των coarser επιπέδων
    for l = 1:Options.Levels-1
        pyramid = [pyramid pyramid_cell{l}(:)' .* 2^(-l)];
    end

    % Στάθμιση των finer επιπέδων
    pyramid = [pyramid pyramid_cell{Options.Levels}(:)'... 
        .* 2^(1-Options.Levels)];

    % Στο σημείο αυτό τοποθετείται στην εκάστοτε σειρά το διάνυσμα της 
    % εικόνας που έχει παραχθεί από την πυραμίδα της εκάστοτε εικόνας 
    pyramid_all(f,:) = pyramid;


end

Pyramid_Vectors = pyramid_all;

end