%% Extortionate Player Class
% A player who demands an extortionate share in iterated prisoner's
% dilemma. See Press and Dyson (2012) for theory.
% Constructor values:
%
% * Phi, chi: doubles, value bounds according to Press and Dyson (2012)
% * (optional) Payoff matrix: payoff-matrix for player 1
%

classdef PlayerExtortionateRandom < Player
    
    properties
    end
    
    methods
        %% Constructor
        function obj = PlayerExtortionateRandom(Phi,chi,varargin)
            %%%
            % If no payoff values passed, assume standard PD values
            if nargin == 2
                R = 3;
                T = 5;
                S = 0;
                P = 1;
            elseif nargin == 3
                Payoffs = varargin{1};
                R = Payoffs(1,1);
                T = Payoffs(2,1);
                S = Payoffs(1,2);
                P = Payoffs(2,2);
            else
                error('Inputs must be Phi, chi and optional payoff matrix')
            end
            
            %%%
            % Validate Phi and chi values
            if ~(chi >= 1)
                error('chi must be >= 1')
            end
            
            maxPhi = (P-S) / ((P-S) + chi*(T-P));
            
            if ~(Phi > 0)
                error('Phi must be > 0')
            end
            
            if ~(Phi <= maxPhi)
                error(['Maximum allowed Phi for chi of ' num2str(chi) ' is: ' num2str(maxPhi)])
            end
            
            %%%
            % Compute probabilities for extortionate strategy
            p1 = 1 - Phi*(chi-1)*(R-P)/(P-S);
            p2 = 1 - Phi*(1 + chi*(T-P)/(P-S));
            p3 = Phi*(chi + (T-P)/(P-S));
            p4 = 0;
            
            %%%
            % Pass to superclass constructor (random initial strategy)
            obj = obj@Player([p1 p2;p3 p4],round(rand()));
        end
    end
    
end

