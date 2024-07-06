```mermaid
graph TD
    A[Final_Experiment.m] -->|1. Get images directory and form the imageDatastore| B[imageDatastore]
    B -->|2. Split the datastore| C[splitEachLabel]
    C -->|3. Split the datastore into training and testing sets| D[splitTheDatastore2]
    D -->|4. Generate SIFT descriptors using Dense SIFT| E[denseSIFTVN]
    E -->|5. Format the Dictionary and extract SIFT matrices| F[DictionaryFormationVN]
    F -->|6. Compute histograms using Spatial Pyramid| G[SpatialPyramidVN]
    G -->|7. Compute histogram intersection| H[hist_intersection_VN]
    H -->|8. Train SVM model| I[fitcecoc]
    I -->|9. Store model and results| J[resultsTable]

    subgraph "Final_Experiment.m"
        A
        B
        C
        D
        E
        F
        G
        H
        I
        J
    end

    subgraph "splitTheDatastore2.m"
        D
    end

    subgraph "denseSIFTVN.m"
        E
    end

    subgraph "DictionaryFormationVN.m"
        F
    end

    subgraph "SpatialPyramidVN.m"
        G
    end

    subgraph "hist_intersection_VN.m"
        H
    end