function varargout = splitTheDatastore2(datastore,newlabels, ...
                                       optional)

%% Description
%  ------------------------------------------------------------------------
%  A function that splits the datastore into training and testing 
%  datastores based on user's input that decides whether the data should be 
%  processed to have equal number of labels or not. The optional variable 
%  opt gives the user the choise to either return the training and testing 
%  label tables with the count of the former or not.


% Inputs:
% -------------------------------------------------------------------------
% => datastore:     The imageDatastore that contains the raw data.
% => optional:      Char or string variable that takes two discrete values: 
%                   "Equal" or "Proceed". Based on one of the two, the 
%                   appropriate measures are taken to treat the splitting 
%                   procedure.
% => initialLabels: A variable that contains the labels that are extracted 
%                   from the initial datastore.

% Outputs: 
% => varargout:     As the name depicts, a variable argument output, that
%                   based on the option variable returns the training and 
%                   testing variables.If the optional variable's optional 
%                   flag is true, then the function returns the table of 
%                   training and testing datastores that contain both the 
%                   labels and the count of them for the user to process.
arguments (Input)

    datastore          {mustBeUnderlyingType(datastore, ...
                                             ['matlab.io.datastore.' ...
                                             'ImageDatastore'])} 

    newlabels          {mustBeNonempty} 

    optional.flag      {mustBeNumericOrLogical} = false
    
    

end

%% Message for the user and setting the option of label data management.

if numel(nargin) < 4 

           

            % fprintf('So you have chosen...biases\n')
            [Trainds,Testds] = splitEachLabel(datastore,0.7,'randomized');
            trainlabelcount = countEachLabel(Trainds);
            testlabelcount = countEachLabel(Testds);
             
            
            if optional.flag
                varargout = {Trainds,Testds,trainlabelcount,testlabelcount};
            else
                varargout = {Trainds,Testds};
            end


else

    error("Too many function inputs")

end


end