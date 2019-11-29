pragma solidity ^0.5.0;

contract HighLow{
     /* ----- importing card Library ------ */
    
    enum Suit { Clubs, Diamonds, Hearts, Spades }
    enum Value { Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, King, Queen, Ace }
    enum Bet { None, High, Low }
    


    /// We choose the following order : 1) value, 2) suit as convention for announcing
    /// When a new card is announced, it should be "8 of spade", not "spade of 8"
    
    uint[52] deck;
        
    uint currentCard = 200;
    
    struct Player {
        string player_name;
        uint value;
        Bet playerBet;
        uint betValue;
    }

    
    /// Shuffle cards from the deck
    function shuffleDeck() internal {
     for (uint256 i = 0; i < deck.length; i++) {
        uint256 n = i + uint256(keccak256(abi.encodePacked(now))) % (deck.length - i);
        uint256 temp = deck[n];
        deck[n] = deck[i];
        deck[i] = temp;
     }
    }
    
    function getCardValue() internal view returns(Bet) {
        uint suit = deck[currentCard]/uint(13);
        uint val = deck[currentCard] - (suit*uint(13));
        if(val < 6) return Bet.Low;
        else return Bet.High;
    }
    
    function nextCard() internal{
        if(currentCard == 200){
            shuffleDeck();
            currentCard = 1;
        }
        else{
         currentCard  = currentCard + 1;
        }
    }
    
    function checkStatus() internal view returns(bool){
       if(currentCard == 42){
           return true;
       }
       else{
           return false;
       }
    }
    
    function getCardString() internal view returns(string memory){
        
        uint  suit = deck[currentCard]/uint(13);
        uint  val = deck[currentCard] - (suit*uint(13));
        string memory card;
        if(val == 0) card = "Ace of";
        if(val == 1) card = "2 of";
        if(val == 2) card = "3 of";
        if(val == 3) card = "4 of";
        if(val == 4) card = "5 of";
        if(val == 5) card = "6 of";
        if(val == 6) card = "7 of";
        if(val == 7) card = "8 of";
        if(val == 8) card = "9 of";
        if(val == 9) card = "10 of";
        if(val == 10) card = "Jack of";
        if(val == 11) card = "Queen of";
        if(val == 12) card = "King of";
        
        if(suit == 0) card = concat(card," Clubs");
        if(suit == 1) card = concat(card," Hearts");
        if(suit == 2) card = concat(card," Diamonds");
        if(suit == 3) card = concat(card," Spades");
        
        return card;
        
    }
    
    // copied from internet
    function concat(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory bytes_a = bytes(_a);
        bytes memory bytes_b = bytes(_b);
        string memory length_ab = new string(bytes_a.length + bytes_b.length);
        bytes memory bytes_c = bytes(length_ab);
        uint k = 0;
        for (uint i = 0; i < bytes_a.length; i++) bytes_c[k++] = bytes_a[i];
        for (uint i = 0; i < bytes_b.length; i++) bytes_c[k++] = bytes_b[i];
        return string(bytes_c);
    }
    
    
    /*  ------- done -------- */
    
    
        uint public numOfPlayers;
        uint currentPlayer;
        string cardString;
        Player[] players;
        
        enum State { Initial, AddPlayers, Bets, Done, NewGame }
        
        State state;
        
        constructor() public{
            for(uint i=0;i<52;i++)
              {
                  deck[i]= i;
              }
            shuffleDeck();
            numOfPlayers = 0;
            currentPlayer = 0;
            state = State.NewGame;
            players.length = 0;
        }

        function incr() public returns(string memory){
            numOfPlayers = numOfPlayers + 1;
            return "done";
        }
        function showin() public view returns(uint){
            return numOfPlayers;
        }

        function startgame() public{
            state = State.Initial;
        }

        // to set the number of players in the house
        function setNumOfPlayers(uint _val) public returns(string memory) {
            if(state == State.Initial)
            {    
                if( _val >= 0 )
                   {
                       numOfPlayers  = _val;
                       state = State.AddPlayers;
                       if(state==State.AddPlayers)
                        {
                            return "changed";
                        }
                        else{
                            return "unchanged";
                        }
                   }
                else{
                    return "Number of players should be >=0";
                }
            }
            else{
                return "Game is going on, the number of players cannot be modified (:";
            }
        }
        
        // returns current Player while bets are taking place
        function showCurrentPlayer() public view returns(string memory) {
            if(state == State.Bets){
                return players[currentPlayer].player_name;
            }
            else{
                return "Currently Bets are not taken.";
            }
        }
    
        // if state == Bets, the function records the bets of each player in 
        function setPlayer(string memory _player_name) public {
            if(state == State.AddPlayers){
                  Player memory new_player = Player({
                  player_name: _player_name,
                  playerBet: Bet.None,
                  betValue: 0,
                  value: 100
                });
                players.push(new_player);
                currentPlayer = currentPlayer + 1;
                if(currentPlayer == numOfPlayers){
                  currentPlayer = 0;
                  state = State.Bets;
                }
            }
        }

        function sendPlaynum() public view returns(uint){
            return currentPlayer + 1;
        }
     
        //@params _betval : the bet placed by the current player
        //@params _val : High or Low
        // if state == Bets, the function records the bets of each player in 
        // sequence
        function setBet(uint _betval, string memory _val) public{
            if(state == State.Bets){
                players[currentPlayer].betValue = players[currentPlayer].value;
                if( players[currentPlayer].betValue > _betval)
                    {
                        players[currentPlayer].betValue =  _betval;
                    }
                players[currentPlayer].value = players[currentPlayer].value -  players[currentPlayer].betValue;
                if(keccak256(abi.encodePacked((_val)))==keccak256(abi.encodePacked(("high")))  ){
                        players[currentPlayer].playerBet = Bet.High;
                    }
                if(keccak256(abi.encodePacked((_val)))==keccak256(abi.encodePacked(("low"))) ){
                    players[currentPlayer].playerBet = Bet.Low;
                }
                currentPlayer = currentPlayer + 1;
                state = State.Done;
                if(currentPlayer == numOfPlayers){
                  currentPlayer = 0;        
                }
            }
        }
        
        // function to calculate rewards after everyone has set their bets
        function calculateRewards() public returns(string memory) {
            if(state == State.Done){
                // To be implemented in CardLib to initialize next card 
                nextCard();
                // returns the current Cards value (if it is Bet.high or Bet.low )
                Bet cardValue = getCardValue();
                // returns the cardString e.g "8 of Spades"
                cardString = getCardString();
                
                for (uint i = 0; i < numOfPlayers; i++) {
                    if(cardValue == players[i].playerBet)
                        players[i].value = players[i].value +  3*players[i].betValue;
                    // Setting back to None
                    players[i].playerBet = Bet.None;
                    players[i].betValue = 0;
                }
                
                // Logic for next bet
                //   To Be implemented according 
                //            to CardLib Functions
                bool check = checkStatus();
                if(check==true){
                    reintialize();
                }
                else{
                    state = State.Bets;
                }
                return cardString;
            }
            else
                return "Bets are not Done yet (:";
        }
        
        function showPreviousCard() public view returns(string memory) {
            return cardString;
        }
        
        function reintialize() internal{
            numOfPlayers = 0;
            currentPlayer = 0; 
            state = State.NewGame;
            players.length = 0;
            shuffleDeck();
            currentCard = 200;
        }
        
        function stateOfGame() public view returns(string memory) {
            if(state == State.NewGame){
                return "Press To Start";
            }
            if(state==State.Initial){
                return "Set the number of Players :)";
            }
            if(state==State.AddPlayers){
                return "Add the names of the player in sequence :)";
            }
            if(state==State.Bets){
                return "Place bets when your turn comes :)";
            }
            if(state==State.Done){
                return "Click on calculateRewards :)";
            }
        }

        function states() public view returns(uint) {
            if(state == State.NewGame){
                return 4;
            }
            if(state==State.Initial){
                return 0;
            }
            if(state==State.AddPlayers){
                return 1;
            }
            if(state==State.Bets){
                return 2;
            }
            if(state==State.Done){
                return 3;
            }
        }

        
        function reslname() public view returns(string memory){
            uint mi = 0;
            uint winner = 0;
            for (uint i = 0; i < numOfPlayers; i++) {
                    if(mi < players[i].value)
                        {
                            mi = players[i].value;
                            winner = i;
                        }
                }
            return players[winner].player_name;
        }

        function reslval() public view returns(uint){
            uint mi = 0;
            uint winner = 0;
            for (uint i = 0; i < numOfPlayers; i++) {
                    if(mi < players[i].value)
                        {
                            mi = players[i].value;
                            winner = i;
                        }
                }
            return players[winner].value;
        }

        function resind() public view returns(uint){
            uint mi = 0;
            uint winner = 0;
            for (uint i = 0; i < numOfPlayers; i++) {
                    if(mi < players[i].value)
                        {
                            mi = players[i].value;
                            winner = i;
                        }
                }
            return winner + 1;
        }
        
        function showPlayerValue(string memory _playername) public view returns(uint) {
            for(uint256 i=0;i<players.length;i++){
                if(keccak256(abi.encodePacked((players[i].player_name)))==keccak256(abi.encodePacked((_playername)))){
                    return players[i].value;
                }
            }
            return 1000000;
        }
        
        function exitGame() public{
            reintialize();
        }
        
}
