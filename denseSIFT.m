function features = denseSIFTVasilakis(grayTrainds,grayTestds)
    
    arguments (Input)

        grayTrainds          {mustBeUnderlyingType(grayTrainds, ...
                                                ['matlab.io.datastore.' ...
                                                'TransformedDatastore'])}


        grayTestds           {mustBeUnderlyingType(grayTestds, ...
                                                ['matlab.io.datastore.' ...
                                                'TransformedDatastore'])}


    end

    reset(grayTrainds);
    reset(grayTestds);
    while hasdata(grayTrainds)
          img = read(grayTrainds);

          [hgt wid] = size(img);

          if 
    end


end