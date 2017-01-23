classdef PlayerAllD < Player
   
    properties
    end
    
    methods
        %% Constructor
        % Pass AllD-values to superclass constructor
        function obj = PlayerAllD()
            obj = obj@Player([0 0;0 0],1);
        end
    end
    
end

