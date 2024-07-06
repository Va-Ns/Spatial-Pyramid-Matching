# Spatial Pyramid Matching Project

This repository contains MATLAB code for performing spatial pyramid matching on a dataset of scene categories. The project includes various scripts for feature extraction, dictionary formation, and classification using support vector machines (SVM).

## Project Structure

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

## How to Run

To run this project:
1. Ensure MATLAB is installed on your system.
2. Clone this repository to your local machine.
3. Place your dataset in the `scene_categories/`directory.
4. Open MATLAB and navigate to the cloned project directory.
5. Run the `Final_Experiment.m` script to start the image classification pipeline.

```matlab
run('Final_Experiment.m')
```

## Disclaimer

This repository is a simple form of reproduction with quite a few changes compared to the initial files that are provided in the ICCV. In keeping with that theme, one can identify files, such as `denseSIFTVN.m`, `DictionaryFormationVN.m`, that belong in the initial draft of the contributors yet are important for the completion of this work. All acknowledgements for those files go to the authors!

## License

Following the notion of the authors, this code is for teaching/research purposes only.

## Images 

![mermaid-diagram-2024-07-06-235543](https://github.com/Va-Ns/Spatial-Pyramid-Matching/assets/68824495/64712b1b-7c99-4b34-b7f7-635428baeba7)

![image](https://github.com/Va-Ns/Spatial-Pyramid-Matching/assets/68824495/5e44a75d-d6c9-4907-a38d-e485f052d947)

*Progression of the loss function for optimizing some of the hyperparameters of the SVM*

![image](https://github.com/Va-Ns/Spatial-Pyramid-Matching/assets/68824495/0bef13bb-69fe-4ce3-88fb-eb535ca6a065)

*Progression of the loss function for optimizing one of the hyperparameters of the SVM*

## Table of results

| Pyramid Levels | Number of Centers | Optimization Parameter         | Mean Accuracy         |
|----------------|-------------------|--------------------------------|-----------------------|
| 2              | 200               | BoxConstraint                  | 71.7507418397626      |
| 2              | 200               | BoxConstraint & KernelScale    | 71.3946587537092      |
| 2              | 200               | All                            | 71.6320474777448      |
| 2              | 400               | BoxConstraint                  | 71.6023738872404      |
| 2              | 400               | BoxConstraint & KernelScale    | 71.8397626112760      |
| 2              | 400               | All                            | 70.5934718100890      |
| 3              | 200               | BoxConstraint                  | 76.0237388724036      |
| 3              | 200               | BoxConstraint & KernelScale    | 75.1335311572700      |
| 3              | 200               | All                            | 76.0534124629080      |
| 3              | 400               | BoxConstraint                  | 74.6587537091988      |
| 3              | 400               | BoxConstraint & KernelScale    | 75.9050445103858      |
| 3              | 400               | All                            | **76.9139465875371**  |
