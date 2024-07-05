# Spatial Pyramid Matching Project

This repository contains MATLAB code for performing spatial pyramid matching on a dataset of scene categories. The project includes various scripts for feature extraction, dictionary formation, and classification using support vector machines (SVM).

## Files Description

- **denseSIFTVN.m**: Extracts dense SIFT descriptors from the images.
- **DictionaryFormationVN.m**: Forms a dictionary of visual words using k-means clustering.
- **Final_Experiment.m**: Main script to run the experiment, including feature extraction, dictionary formation, spatial pyramid matching, and SVM classification.
- **gaussVN.m**: Applies Gaussian filtering to the images.
- **hist_intersection_VN.m**: Computes the histogram intersection kernel.
- **miniBatchKMeansVN.m**: Performs mini-batch k-means clustering.
- **resultsTable.mat**: Stores the results of the experiments.
- **scene_categories/**: Directory containing the dataset of scene categories.
- **SIFTnormalizationVN.m**: Normalizes SIFT descriptors.
- **SpatialPyramidVN.m**: Constructs spatial pyramid representations of the images.
- **splitTheDatastore2.m**: Splits the image datastore into training and testing sets.

## Usage

1. **Setup**: Ensure you have MATLAB installed and the required toolboxes.
2. **Dataset**: Place your dataset in the `scene_categories/` directory.
3. **Run Experiment**: Execute the `Final_Experiment.m` script to run the entire pipeline.

```matlab
run('Final_Experiment.m')
