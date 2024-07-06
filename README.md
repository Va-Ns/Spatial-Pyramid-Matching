# Spatial Pyramid Matching Project

This repository contains MATLAB code for performing spatial pyramid matching on a dataset of scene categories. The project includes various scripts for feature extraction, dictionary formation, and classification using support vector machines (SVM).

## Project Highlights

- **Feature Extraction**: Utilizes dense SIFT descriptors to identify points of interest in images.
- **Dictionary Formation**: Forms a dictionary of visual words using k-means clustering.
- **Classification**: Uses a Support Vector Machine classifier with hyperparameter optimization.

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
3. Place your dataset in the [`scene_categories/`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fc%3A%2FUsers%2Fvasil%2FOneDrive%2F%CE%A5%CF%80%CE%BF%CE%BB%CE%BF%CE%B3%CE%B9%CF%83%CF%84%CE%AE%CF%82%2FGithub%20projects%2FSpatial%20Pyramid%20Matching%2Fscene_categories%2F%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "c:\Users\vasil\OneDrive\Υπολογιστής\Github projects\Spatial Pyramid Matching\scene_categories\") directory.
4. Open MATLAB and navigate to the cloned project directory.
5. Run the [`Final_Experiment.m`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fc%3A%2FUsers%2Fvasil%2FOneDrive%2F%CE%A5%CF%80%CE%BF%CE%BB%CE%BF%CE%B3%CE%B9%CF%83%CF%84%CE%AE%CF%82%2FGithub%20projects%2FSpatial%20Pyramid%20Matching%2FFinal_Experiment.m%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "c:\Users\vasil\OneDrive\Υπολογιστής\Github projects\Spatial Pyramid Matching\Final_Experiment.m") script to start the image classification pipeline.

```matlab
run('Final_Experiment.m')
```

## Disclaimer

This repository is a simple form of reproduction with quite a few changes compared to the initial files that are provided in the ICCV. In keeping with that theme, one can identify files, such as `denseSIFTVN.m`, `DictionaryFormationVN.m`, that belong in the initial draft of the contributors yet are important for the completion of this work. All acknowledgements for those files go to the authors!

## License

Following the notion of the authors, this code is for teaching/research purposes only.

## Images 

![mermaid-diagram-2024-07-06-235543](https://github.com/Va-Ns/Spatial-Pyramid-Matching/assets/68824495/64712b1b-7c99-4b34-b7f7-635428baeba7)


![image](https://github.com/Va-Ns/Spatial-Pyramid-Matching/assets/68824495/7240d098-e4f0-481e-96f7-4f028e90fe81)

*Progression of the loss function for optimizing all the hyperparameters of the SVM*
