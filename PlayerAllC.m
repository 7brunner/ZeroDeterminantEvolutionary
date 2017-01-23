classdef PlayerAllC < Player
   
    properties
    end
    
    methods
        %% Constructor
        % Pass AllC-values to superclass constructor
        function obj = PlayerAllC()
            obj = obj@Player([1 1;1 1],0);
        end
    end
    
end

