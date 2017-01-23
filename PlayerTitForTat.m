classdef PlayerTitForTat < Player
   
    properties
    end
    
    methods
        %% Constructor
        % Pass tit-for-tat-values to superclass constructor
        function obj = PlayerTitForTat()
            obj = obj@Player([1 0;1 0],0);
        end
    end
    
end

