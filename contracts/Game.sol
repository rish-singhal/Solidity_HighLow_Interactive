pragma solidity ^0.5.0;

contract Game{

    enum active { NO, YES }

    struct Player {
        uint val;
        bytes32 choice;
        uint256 ch;
        active a;
        bool is_taken;
    }

    address payable public owner;
    uint8 public cs;
    uint8 public cc;
    uint8 private count;
    uint8[13][4] private burnDeck;
    mapping (address => Player) private players;
    address payable[] private playerAccts;
    uint gameStart;
    uint any_time;
    uint256 total;

    event NewCard(uint8 CardSuit, uint8 Card);
    event NewPlayer(address Player);
    event NewBet(address Player, uint Value);
    event ChoiceReveal(address Player, string Choice);

    constructor() public payable {
        // require(_time>0,"Betting time cannot be 0");
        owner = msg.sender;
        cs = random(4);
        cc = random(13);
        gameStart = now;
        emit NewCard(cs,cc);
        count = 1;
        any_time = 1;
        total = 0;
    }

    function newBet(bytes32 _choice) public payable {
        require(players[msg.sender].is_taken==true,"Player not registered");
        require(players[msg.sender].a==active.NO,"Player can bet only once in a turn");
        require(now - gameStart <= any_time * 1 seconds,"Betting time over");
        require(msg.value>0,"Bet value cannot be zero");
        uint256 temp = 2 * ( total + msg.value );
        require(address(this).balance>temp,"Bet too large");
        total += msg.value;
        players[msg.sender].a = active.YES;
        players[msg.sender].val = msg.value;
        players[msg.sender].choice = _choice;
        players[msg.sender].ch = 0;
        emit NewBet(msg.sender,msg.value);
    }

    function newPlayer() public {
        require(players[msg.sender].is_taken==false,"Player already exists");
        players[msg.sender].is_taken = true;
        players[msg.sender].a = active.NO;
        playerAccts.push(msg.sender) - 1;
        emit NewPlayer(msg.sender);
    }

    function Reveal(uint256 _rand, uint256 _choice) public {
        require(players[msg.sender].is_taken==true,"Player not registered");
        require(players[msg.sender].a==active.YES,"Player did not bet in this turn");
        require(now - gameStart >= any_time * 1 seconds,"Cannot reveal choice during betting time");
        require(now - gameStart <= any_time * 2 seconds,"Reveal time over");
        require(_choice>0 && _choice<3,"Invalid choice");
        require(players[msg.sender].ch==0,"Choice already revealed");
        uint256 inter = _rand * 10 + _choice;
        bytes32 temp = keccak256(abi.encodePacked(inter));
        require(players[msg.sender].choice==temp,"Invalid hash");
        players[msg.sender].ch = _choice;
        if(_choice==1)
            emit ChoiceReveal(msg.sender,"LOW");
        else
            emit ChoiceReveal(msg.sender,"HIGH");
    }

    function newCard() public {
        require(now - gameStart >= any_time * 2 seconds,"Betting process not over");
        burnDeck[cs][cc] = 1;
        uint8 c = random(13);
        uint8 s = random(4);
        while(burnDeck[s][c]==1) {
            c = random(13);
            s = random(4);
        }
        uint256 winner = 0;
        if(c>cc) {
            winner = 2;
        } else if(c<cc) {
            winner = 1;
        } else {
            winner = 3;
        }
        cc = c;
        cs = s;
        if(count==4) {
            count = 1;
            for(uint i = 0; i<4; i++) {
                for(uint j = 0; j<13; j++) {
                    burnDeck[i][j] = 0;
                }
            }
        }
        else {
            count += 1;
        }
        for(uint i = 0; i<playerAccts.length; i++) {
            if(players[playerAccts[i]].a==active.NO) {
                continue;
            }
            if(winner==3) {
                owner.transfer(players[playerAccts[i]].val);
                players[playerAccts[i]].a = active.NO;
                continue;
            }
            if(players[playerAccts[i]].ch!=winner) {
                players[playerAccts[i]].a = active.NO;
            } else {
                players[playerAccts[i]].a = active.NO;
                playerAccts[i].transfer(2*players[playerAccts[i]].val);
            }
        }
        total = 0;
        emit NewCard(cs,cc);
        gameStart = now;
    }

    function fallback() external payable {
        require(msg.value>0,"Value cannot be 0");
    }

    function random(uint256 _num) private view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%_num);
    }

}
