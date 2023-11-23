% clear;clc;close all
% Example of how to use the BuildPyramid function
% set image_dir and data_dir to your actual directories
image_dir = 'images'; 
data_dir = 'data';

% for other parameters, see BuildPyramid

fnames = dir(fullfile(image_dir, '*.jpg'));
num_files = size(fnames,1);
filenames = cell(num_files,1);

for f = 1:num_files
	filenames{f} = fnames(f).name;
end

% Return pyramid descriptors for all files in filenames
pyramid_all = BuildPyramid(filenames,image_dir,data_dir);

%% Χτίσιμο πυραμίδας με 400 κέντρα και χωρίς παραγωγή άλλων χαρακτηριστικών.

% Build a pyramid with a different dictionary size without re-generating 
% the sift descriptors.
params.dictionarySize = 400;
pyramid_all2 = BuildPyramid(filenames,image_dir,data_dir,params,1);

%% Όπως και πάνω αλλά με αύξηση στον αριθμό των textons,μείωση του grid spacing και 2 επίπεδα πυραμίδας.

% Control all the parameters
params.maxImageSize = 1000;
params.gridSpacing = 1;
params.patchSize = 16;
params.dictionarySize = 200;
params.numTextonImages = 300;
params.pyramidLevels = 2;
pyramid_all3 = BuildPyramid(filenames,image_dir,[data_dir '2'],params,1);

%% Υλοποίησης συνάρτησης ιστογραμματικής τομής
% Compute histogram intersection kernel
K = hist_isect(pyramid_all3, pyramid_all3); 

% For faster performance, compile and use hist_isect_c:
% K = hist_isect_c(pyramid_all, pyramid_all);
