classdef Game
    %GAME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Payoffs1
        Payoffs2
    end
    
    methods
        %% Constructor
        function obj = Game(Payoffs1,varargin)
            %%%
            % Validate first payoff matrix
            Payoffs1Size = size(Payoffs1);
            if (length(Payoffs1Size) ~= 2)
                error('Payoff must be 2x2 matrix')
            else
                if Payoffs1Size(1) ~= 2 || Payoffs1Size(2) ~= 2
                    error('Payoff must be 2x2 matrix')
                end
            end
            
            obj.Payoffs1 = Payoffs1;
            
            %%%
            % If second matrix not passed, assume symmetric game, otherwise
            % validate payoff matrix 2
            if nargin==1
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
        
        function [Player1,Player2] = playRound(obj,Player1,Player2)
            [Player1,Move1] = Player1.playMove(Player2.LastMovePlayed);
            [Player2,Move2] = Player2.playMove(Player1.LastMovePlayed);
            
            Payoff1 = obj.Payoffs1(Move1+1,Move2+1);
            Payoff2 = obj.Payoffs2(Move1+1,Move2+1);
            
            Player1.PayoffHistory(Player1.LastGame) = Payoff1;
            Player2.PayoffHistory(Player2.LastGame) = Payoff2;
        end
        
        function [Player1,Player2] = playNRounds(obj,NRounds,Player1,Player2)
            for i = 1:NRounds
                [Player1,Player2] = playRound(obj,Player1,Player2);
            end
        end
    end
    
end

