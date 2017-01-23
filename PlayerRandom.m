classdef PlayerRandom < Player
   
    properties
    end
    
    methods
        %% Constructor
        % Pass random values to superclass constructor
        function obj = PlayerRandom()
            obj = obj@Player(random(2),round(random()));
        end
    end
    
end