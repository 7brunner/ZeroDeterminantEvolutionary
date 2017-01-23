%% Player class

classdef Player
    
    properties
        PayoffHistory
        AveragePayoffHistory
        LastGame
        LastMovePlayed  % 0 = cooperate, 1 = defect
        Strategy        % 2x2 matrix (cc, dc, cd, dd)
        InitialStrategy % 0 = cooperate, 1 = defect
    end
    
    properties(Access = protected)
        intArrayLength = 1000;
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
                obj.PayoffHistory = [obj.PayoffHistory,zeros(obj.intArrayLength,1)];
            end
            obj.LastMovePlayed = Move;
        end
        
        %% Get-method for average payoff history
        function AveragePayoffHistory = get.AveragePayoffHistory(obj)
            PayoffHistoryShort = obj.PayoffHistory(1:obj.LastGame);
            CumulativePayoffs = cumsum(PayoffHistoryShort);
            AveragePayoffHistory = CumulativePayoffs ./ [1:length(CumulativePayoffs)]';
        end
        
        %% Reset history method
        function obj = resetHistory(obj)
            obj.PayoffHistory = nan(obj.intArrayLength,1);
            obj.LastMovePlayed = nan;
            obj.LastGame = 0;
        end
    end
    
end

