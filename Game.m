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
        Payoffs1        % 2x2 Payoff matrix for player 1
        Payoffs2        % 2x2 Payoff matrix for player 2
        Population      % cell array of players
        MatchingType    % string either Random, Close or Far
        PlayerTypes     % cell array of player types
        PopulationShareHistory % nxk array of n generations for k player types
        PlayerTypeAvgPayoffHistory % nxk array of n generations for k player types
        LastGeneration  % integer
        DoParallelComputation % Boolean. About 50% performance improvement 
        % (linear over the tested values). Cannot store the results for
        % matched opponents for technical reasons (ie only half as many
        % played games are stored in each generation)
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
            
            %%%
            % Check if matching type string passed, otherwise set to Random
            if length(varargin)<=2
                obj.MatchingType = 'Random';
            else
                MatchingType = varargin{3};
                if ~ismember(MatchingType,{'Random','Close','Far'})
                    error('Matching type must be one of Random, Close or Far')
                end
                obj.MatchingType = MatchingType;
            end
            
            obj.LastGeneration = 0;
            obj.DoParallelComputation = false;
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
                
                NewPlayer = eval([strPlayerType]);
                NewPlayer.PlayerTypeConstructorCall = strPlayerType;
                Population{i} = NewPlayer;
            end
                        
            obj.Population = Population;
            
            %%%
            % Store constructor calls of player types
            obj.PlayerTypes = PlayerTypes;
        end
        
        %% Run one generation tournament
        % Loop over all players and match them with opponent according to
        % defined matching type
        function obj = runOneGenerationTournament(obj,RoundsToPlay)
            if obj.DoParallelComputation
                Population = obj.Population;
                NewPopulation = cell(size(Population));
                parfor i = 1:length(obj.Population(:,1))
                    Player1 = Population{i,1};
                    Player2 = obj.matchOpponent(i);
                    Player1 = playNRounds(obj,RoundsToPlay,Player1,Player2);

                    NewPopulation{i,1} = Player1;
                end
                obj.Population = NewPopulation;
            else
                for i = 1:length(obj.Population(:,1))
                    Player1 = obj.Population{i,1};
                    [Player2,locPlayer2] = obj.matchOpponent(i);
                    [Player1,Player2] = playNRounds(obj,RoundsToPlay,Player1,Player2);

                    obj.Population{i,1} = Player1;
                    obj.Population{locPlayer2,1} = Player2;
                end
            end
        end
        
        %% Match opponent method
        % Matches one opponent according to defined matching type
        function [Player2,locPlayer2] = matchOpponent(obj,locPlayer1)
            switch obj.MatchingType
                case 'Random'
                    vecPositions = 1:length(obj.Population(:,1));
                    vecPositions(locPlayer1) = [];
                    locPlayer2 = vecPositions(ceil(rand()*length(vecPositions)));
                    Player2 = obj.Population{locPlayer2,1};
            end
        end
        
        %% Run n generation tournament
        % Call run one generation tournament and generate next generation n
        % times
        function obj = runNGenerationTournament(obj,NGenerations,RoundsPerGeneration)
            obj.LastGeneration = 0;
            
            %%%
            % Create vectors containing history 
            obj.PopulationShareHistory = nan(NGenerations,length(obj.PlayerTypes));
            obj.PlayerTypeAvgPayoffHistory = nan(NGenerations,length(obj.PlayerTypes));
            
            %%%
            % Loop over generations
            blnConvergence = false;
            iGeneration = 1;
            while ~blnConvergence
                obj = runOneGenerationTournament(obj,RoundsPerGeneration);
                [obj,blnConvergence] = createNextGeneration(obj);
                if iGeneration == NGenerations
                    blnConvergence = true;
                end
                iGeneration = iGeneration + 1;
            end
        end
        
        %% Plot population history method
        function plotPopulationHistory(obj,Title)
            figure
            subplot(2,1,1)
            plot(obj.PopulationShareHistory)
            title([Title ' - Population shares'])

            subplot(2,1,2)
            plot(obj.PlayerTypeAvgPayoffHistory)
            legend(obj.PlayerTypes,'Location','southoutside')
            title('Average payoffs per player type')
        end
    end
    
    methods(Access = protected)
        %% Create next generation method
        % Store share and average scores of each player type in current
        % generation and sample new generation with probablity proportional
        % to average score
        function [obj,blnConvergence] = createNextGeneration(obj)
            obj.LastGeneration = obj.LastGeneration + 1;
            ConstructorCalls = cellfun(@(x) x.PlayerTypeConstructorCall,obj.Population(:,1),'UniformOutput',false);
            Payoffs = cellfun(@(x) x.AveragePayoff,obj.Population);
            if any(isnan(Payoffs))
                warning('NaN in Payoffs')
                Payoffs(isnan(Payoffs)) = 0;
            end
            AvgPayoff = mean(Payoffs);
            
            NewFullConstructorCall = cell(1,length(obj.PlayerTypes)*2);
            
            blnConvergence = false;
            
            for i = 1:length(obj.PlayerTypes)
                %%%
                % Store shares of player type
                strPlayerType = obj.PlayerTypes{i};
                pos = ismember(ConstructorCalls,strPlayerType);
                PopulationShare = sum(pos) / length(obj.Population(:,1));
                obj.PopulationShareHistory(obj.LastGeneration,i) = PopulationShare;
                
                %%%
                % Convergence if one player type has 100% share
                if PopulationShare == 1
                    blnConvergence = true;
                end
                
                %%%
                % Store average fitness of player type
                PlayerTypeAvgPayoff = mean(Payoffs(pos));
                obj.PlayerTypeAvgPayoffHistory(obj.LastGeneration,i) = PlayerTypeAvgPayoff;
                
                %%%
                % Discrete-time replicator dynamics for new population
                % shares. For reference see e.g. Bauso (2016) p. 80
                NewShare = PopulationShare * (1 + (PlayerTypeAvgPayoff - AvgPayoff)/AvgPayoff);
                
                %%%
                % Enter player type and new player shares into new
                % constructor call
                NewFullConstructorCall{i*2-1} = strPlayerType;
                NewFullConstructorCall{i*2} = NewShare;
            end
            
            %%%
            % Create new population with the newly constructed call (same
            % player types, new shares
            obj = createPopulation(obj,length(obj.Population),NewFullConstructorCall{:});
            
            
%             %%%
%             % Sample new population and reset player history
%             NewPopulation = cell(size(obj.Population));
%             SelectionProbability = cumsum(Payoffs/sum(Payoffs));
%             for i = 1:length(obj.Population(:,1))
%                 newLoc = find(SelectionProbability<rand(),1,'last');
%                 if isempty(newLoc); newLoc = 1; end
%                 NewPopulation{i,:} = obj.Population{newLoc,:};
%                 NewPlayer = NewPopulation{i,1};
%                 NewPlayer = NewPlayer.resetHistory;
%                 NewPopulation{i,1} = NewPlayer;
%             end
%             
%             obj.Population = NewPopulation;
        end
    end
    
end

