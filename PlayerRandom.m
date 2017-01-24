classdef PlayerRandom < Player
   
    properties
    end
    
    methods
        %% Constructor
        % Pass random values to superclass constructor
        function obj = PlayerRandom()
            obj = obj@Player(ones(2)*0.5,0);
        end
    end
    
end