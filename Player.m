%% Player class
% General class for 1-memory player.
% Constructor inputs:
% 
% * Strategy: 2x2 matrix of probabilities depending on last move (cc, cd,
% dc, dd)
% * Initialstrategy: Strategy played at first move. 0 (cooperate) or 1 (defect)
% 

classdef Player
    
    properties
        PayoffHistory   % Nx1 vector of payoffs per game
        AveragePayoffHistory % Nx1 vector of cumulated average payoff
        AveragePayoff   % If only the last value is needed
        LastGame        % integer, last used entry of History vector
        LastMovePlayed  % 0 = cooperate, 1 = defect
        Strategy        % 2x2 matrix (cc, dc, cd, dd)
        InitialStrategy % 0 = cooperate, 1 = defect
        PlayerTypeConstructorCall % Is set by generatePopulation method
    end
    
    properties(Access = protected)
        intArrayLength = 1000; % Determine the size by which the history vector grows
    end
    
    methods
        %% Constructor
        % Validate inputs (valid strategy matrix with probabilities and
        % valid initial strategy) and initialize properties
        function obj = Player(Strategy,InitialStrategy)
            %%%
            % Validate inputs
            StrategySize = size(Strategy);
            if (length(StrategySize) ~= 2)
                error('Strategy must be 2x2 matrix')
            else
                if StrategySize(1) ~= 2 || StrategySize(2) ~= 2
                    error('Strategy must be 2x2 matrix')
                end
            end
            
            if any(any(isnan(Strategy))) || any(any(Strategy > 1)) || any(any(Strategy < 0))
                error('Strategy values must lie in [0,1]')
            end
            
            if InitialStrategy ~= 0 && InitialStrategy ~= 1
                error('Initial Strategy move must be zero (cooperate) or 1 (defect)')
            end
            
            %%%
            % Set properties
            obj.Strategy = Strategy;
            obj.PayoffHistory = nan(obj.intArrayLength,1);
            obj.LastMovePlayed = nan;
            obj.InitialStrategy = InitialStrategy;
            obj.LastGame = 0;
        end
        
        %% Play move method
        % Output the next move according to strategy and opponent's last
        % move
        function [obj,Move] = playMove(obj,LastMoveOpponent)
            %%%
            % Validate inputs
            if LastMoveOpponent ~= 0 && LastMoveOpponent ~= 1 && ~isnan(LastMoveOpponent)
                error('Last Opponent move must be zero (cooperate) or 1 (defect)')
            end
            
            %%%
            % Next move: look up in strategy
            if isnan(LastMoveOpponent) || isnan(obj.LastMovePlayed)
                Move = obj.InitialStrategy;
            else
                p = obj.Strategy(obj.LastMovePlayed+1,LastMoveOpponent+1);
                Move = rand() >= p;
            end
            
            %%%
            % Increment counter and store last move
            obj.LastGame = obj.LastGame + 1;
            if obj.LastGame > length(obj.PayoffHistory)
                obj.PayoffHistory = [obj.PayoffHistory;zeros(obj.intArrayLength,1)];
            end
            obj.LastMovePlayed = Move;
        end
        
        %% Get-method for average payoff history
        function AveragePayoffHistory = get.AveragePayoffHistory(obj)
            PayoffHistoryShort = obj.PayoffHistory(1:obj.LastGame);
            CumulativePayoffs = cumsum(PayoffHistoryShort);
            AveragePayoffHistory = CumulativePayoffs ./ [1:length(CumulativePayoffs)]';
        end
        
        %% Get-method for average payoff
        % If only the last payoff value is needed
        function AveragePayoff = get.AveragePayoff(obj)
            SumPayoffs = sum(obj.PayoffHistory(1:obj.LastGame));
            AveragePayoff = SumPayoffs / obj.LastGame;
        end
        
        %% Reset history method
        function obj = resetHistory(obj)
            obj.PayoffHistory = nan(obj.intArrayLength,1);
            obj.LastMovePlayed = nan;
            obj.LastGame = 0;
        end
    end
    
end

