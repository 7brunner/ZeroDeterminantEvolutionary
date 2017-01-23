%% Game
% General class for 2-player game. 
% Constructor inputs:
% 
% * (optional) Payoffs1: payoff matrix for player 1. Defaults to standard
% prisoner's dilemma values
% * (optional): Payoffs2: payoff matrix for player 2. Defaults to transpose
% of player 1 payoffs
% 

classdef Game
    
    properties
        Payoffs1
        Payoffs2
        Population
    end
    
    methods
        %% Constructor
        function obj = Game(Payoffs1,varargin)
            %%%
            % If no payoff matrix passed, set standard PD values
            if isempty(varargin)
                Payoffs1 = [3 0;5 1];
            else
                Payoffs1Size = size(Payoffs1);
                if (length(Payoffs1Size) ~= 2)
                    error('Payoff must be 2x2 matrix')
                else
                    if Payoffs1Size(1) ~= 2 || Payoffs1Size(2) ~= 2
                        error('Payoff must be 2x2 matrix')
                    end
                end
            end
            
            obj.Payoffs1 = Payoffs1;
            
            %%%
            % If second matrix not passed, assume symmetric game, otherwise
            % validate payoff matrix 2
            if length(varargin)<=1
                obj.Payoffs2 = transpose(Payoffs1);
            else
                Payoffs2 = varargin{1};
                Payoffs2Size = size(Payoffs2);
                if (length(Payoffs2Size) ~= 2)
                    error('Payoff must be 2x2 matrix')
                else
                    if Payoffs2Size(2) ~= 2 || Payoffs2Size(2) ~= 2
                        error('Payoff must be 2x2 matrix')
                    end
                end
                
                obj.Payoffs2 = Payoffs2;
            end
        end
        
        %% Play one round method
        % Queries the next strategy from each player and computes payoffs
        % according to payoff matrix
        function [Player1,Player2] = playRound(obj,Player1,Player2)
            [Player1,Move1] = Player1.playMove(Player2.LastMovePlayed);
            [Player2,Move2] = Player2.playMove(Player1.LastMovePlayed);
            
            Payoff1 = obj.Payoffs1(Move1+1,Move2+1);
            Payoff2 = obj.Payoffs2(Move1+1,Move2+1);
            
            Player1.PayoffHistory(Player1.LastGame) = Payoff1;
            Player2.PayoffHistory(Player2.LastGame) = Payoff2;
        end
        
        %% Play n rounds method
        % Calls the play one round method n times
        function [Player1,Player2] = playNRounds(obj,NRounds,Player1,Player2)
            for i = 1:NRounds
                [Player1,Player2] = playRound(obj,Player1,Player2);
            end
        end
        
        %% Create population method
        % Creates a population of agents of different classes
        function obj = createPopulation(obj,PopulationSize,varargin)
            %%%
            % Inputs: Populationsize and value pairs of player type and
            % shares
            PlayerTypes = varargin(1:2:end-1);
            PlayerShares = cell2mat(varargin(2:2:end));
            PlayerShares = PlayerShares / sum(PlayerShares);
            PlayerShares = cumsum(PlayerShares);
            
            intPlayerType = 1;
            strPlayerType = PlayerTypes{1};
            
            %%%
            % Create population in loop by rounding respective shares
            Population = cell(PopulationSize,1);
            
            for i = 1:PopulationSize
                
                if i == round(PopulationSize*PlayerShares(intPlayerType)) + 1
                    intPlayerType = intPlayerType + 1;
                    strPlayerType = PlayerTypes{intPlayerType};
                end
                
                Population{i} = eval([strPlayerType]);
            end
            
            obj.Population = Population;
        end
        
        %% Run tournament
        % Loop over all players and match them with random opponent
        
        %% Create next generation
        % Store share and average scores of each player type in current
        % generation and sample new generation with probablity proportional
        % to average score
    end
    
end

