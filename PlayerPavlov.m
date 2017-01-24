classdef PlayerPavlov < Player
    
    properties
    end
    
    methods
        %% Constructor
        % Pass Pavlov-values to superclass constructor
        function obj = PlayerPavlov()
            obj = obj@Player([1 0;0 1],0);
        end
    end
    
end

