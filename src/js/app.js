App = {
  web3Provider: null,
  contracts: {},
  init: async function () {
    // Load pets

    return await App.initWeb3();
  },

  initWeb3: async function () {
    // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
      } catch (error) {
        // User denied account access...
        console.error("User denied account access");
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {

      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function () {

    $.getJSON('HighLow.json', function (data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var GameArtifact = data;
      App.contracts.Game = TruffleContract(GameArtifact);

      // Set the provider for our contract
      App.contracts.Game.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the adopted pets
      return App.gameState();
    });
    return App.bindEvents();
  },
  gameState: function () {
    var gameInstance;
    App.contracts.Game.deployed().then(function (instance) {
      gameInstance = instance;
      return gameInstance.states.call();
    }).then(function (value) {
      value = value.toNumber();
      console.log(value);
      if (value == 4) {
        $(".gamestate").show();
        $(".setnumber").hide();
        $('.endresult').hide();
        $(".setplayname").hide();
        $('.calcrewresult').hide();
        $(".setbet").hide();
        $('.startgame').show();
        $('.rstartgame').hide();
        $('.calcrew').hide();
      } else if (value == 0) {
        $(".gamestate").show();
        $(".setnumber").show();
        $('.endresult').hide();
        $(".setplayname").hide();
        $('.calcrewresult').hide();
        $(".setbet").hide();
        $('.startgame').hide();
        $('.rstartgame').show();
        $('.calcrew').hide();
      } else if (value == 1) {
        $(".gamestate").show();
        $(".setnumber").hide();
        $(".setplayname").show();
        $(".setbet").hide();
        $('.startgame').hide();
        $('.endresult').hide();
        $('.rstartgame').show();
        $('.calcrewresult').hide();
        $('.calcrew').hide();
      } else if (value == 2) {
        $(".gamestate").show();
        $(".setnumber").hide();
        $(".setplayname").hide();
        $(".setbet").show();
        $('.endresult').hide();
        $('.startgame').hide();
        $('.rstartgame').show();
        $('.calcrew').hide();
        $('.calcrewresult').hide();
      } else {
        $(".gamestate").show();
        $(".setnumber").hide();
        $(".setplayname").hide();
        $('.endresult').hide();
        $(".setbet").hide();
        $(".calcrew").show();
        $('.startgame').hide();
        $('.rstartgame').show();
        $('.calcrewresult').hide();
      }


      return App.gameString();
    }).catch(function (err) {
      console.log(err.message);
    });
  },
  gameString: function () {
    var gameInstance;
    App.contracts.Game.deployed().then(function (instance) {
      gameInstance = instance;
      return gameInstance.stateOfGame.call();
    }).then(function (value) {
      console.log(value);
      $("#gamestate").text(value.toString());
      return App.playernum();
    }).catch(function (err) {
      console.log(err.message);
    });
  },
  playernum: function () {
    var gameInstance;
    App.contracts.Game.deployed().then(function (instance) {
      gameInstance = instance;
      return gameInstance.sendPlaynum.call();
    }).then(function (value) {
      value = value.toNumber();
      console.log(value);
      $("#plynum1").text(value.toString());
      $("#plynum2").text(value.toString());
      $("#plyn2").text(value.toString());
      return App.playernme();
    }).catch(function (err) {
      console.log(err.message);
    });
  },
  playernme: function () {
    var gameInstance;
    App.contracts.Game.deployed().then(function (instance) {
      gameInstance = instance;
      return gameInstance.showCurrentPlayer.call();
    }).then(function (value) {
      console.log(value);
      $("#plynme2").text(value.toString());
      $("#plynm2").text(value.toString());
    }).catch(function (err) {
      console.log(err.message);
    });
  },
  setNumber: function () {
    var gameInstance;
    var num = $('#numplayer').val();

    num = parseInt(num);
    console.log(num);
    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.Game.deployed().then(function (instance) {
        gameInstance = instance;
        return gameInstance.setNumOfPlayers(num, {
          from: account
        });
      }).then(function (value) {
        console.log(value);
        $('#numplayer').val('0');
        return App.gameState();
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  },
  setName: function () {
    var gameInstance;
    var name = $('#playername').val();

    console.log(name);
    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.Game.deployed().then(function (instance) {
        gameInstance = instance;
        return gameInstance.setPlayer(name, {
          from: account
        });
      }).then(function (value) {
        console.log(value);
        $('#playername').val('Enter Name');
        return App.gameState();
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  },
  setHigh: function () {
    var gameInstance;
    var bval = $('#betvalue').val();

    bval = parseInt(bval);
    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.Game.deployed().then(function (instance) {
        gameInstance = instance;
        return gameInstance.setBet(bval, "high", {
          from: account
        });
      }).then(function (value) {
        console.log(value);
        $('#betvalue').val('Set Bet-Value');
        return App.nexthl();
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  },
  setLow: function () {
    var gameInstance;
    var bval = $('#betvalue').val();
    bval = parseInt(bval);
    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.Game.deployed().then(function (instance) {
        gameInstance = instance;
        return gameInstance.setBet(bval, "low", {
          from: account
        });
      }).then(function (value) {
        console.log(value);
        return App.nexthl();
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  },
  nexthl: function () {
    $(".gamestate").hide();
    $(".setnumber").hide();
    $(".setplayname").hide();
    $(".setbet").hide();
    $('.endresult').hide();
    $(".calcrew").show();
    $('.startgame').hide();
    $('.rstartgame').show();
    $('.calcrewresult').hide();
  },
  calcrew: function () {
    var gameInstance;
    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.Game.deployed().then(function (instance) {
        gameInstance = instance;
        return gameInstance.calculateRewards({
          from: account
        });
      }).then(function (value) {
        console.log(value);
        $(".calcrew").hide();
        $('.calcrewresult').show();
        return App.prevcard();
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  },
  prevcard: function () {
    var gameInstance;
    App.contracts.Game.deployed().then(function (instance) {
      gameInstance = instance;
      return gameInstance.showPreviousCard.call();
    }).then(function (value) {
      console.log("prevcard");
      console.log(value);
      $("#card").text(value.toString());
      return App.currval();
    }).catch(function (err) {
      console.log(err.message);
    });
  },
  currval: function () {
    var gameInstance;
    name = $("#plynm2").text();
    App.contracts.Game.deployed().then(function (instance) {
      gameInstance = instance;
      return gameInstance.showPlayerValue.call(name);
    }).then(function (value) {
      console.log(value);
      value = value.toNumber();
      $("#cbal").text(value.toString());
    }).catch(function (err) {
      console.log(err.message);
    });
  },
  playernme: function () {
    var gameInstance;
    App.contracts.Game.deployed().then(function (instance) {
      gameInstance = instance;
      return gameInstance.showCurrentPlayer.call();
    }).then(function (value) {
      console.log(value);
      $("#plynme2").text(value.toString());
      $("#plynm2").text(value.toString());
    }).catch(function (err) {
      console.log(err.message);
    });
  },
  exitgame: function () {
    var gameInstance;
    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.Game.deployed().then(function (instance) {
        gameInstance = instance;
        return gameInstance.exitGame({
          from: account
        });
      }).then(function (value) {
        console.log(value);
        return App.gameState();
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  },
  winid: function () {
    var gameInstance;
    App.contracts.Game.deployed().then(function (instance) {
      gameInstance = instance;
      return gameInstance.resind.call();
    }).then(function (value) {
      console.log(value);
      value = value.toNumber();
      $("#winplyn").text(value.toString());
      return App.winname();
    }).catch(function (err) {
      console.log(err.message);
    });
  },
  winname: function () {
    var gameInstance;
    App.contracts.Game.deployed().then(function (instance) {
      gameInstance = instance;
      return gameInstance.reslname.call();
    }).then(function (value) {
      console.log(value);
      $("#winplynm").text(value.toString());
      return App.winval();
    }).catch(function (err) {
      console.log(err.message);
    });
  },
  winval: function () {
    var gameInstance;
    App.contracts.Game.deployed().then(function (instance) {
      gameInstance = instance;
      return gameInstance.reslval.call();
    }).then(function (value) {
      console.log(value);
      $("#wincbal").text(value.toString());
      $('.endresult').show();
    }).catch(function (err) {
      console.log(err.message);
    });
  },
  newgame: function () {
    var gameInstance;
    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.Game.deployed().then(function (instance) {
        gameInstance = instance;
        return gameInstance.startgame({
          from: account
        });
      }).then(function (value) {
        console.log(value);
        return App.gameState();
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  },
  bindEvents: function () {
    $(document).on('click', '#submit', App.setNumber);
    $(document).on('click', '#startgame', App.newgame);
    $(document).on('click', '#submit2', App.setName);
    $(document).on('click', '#submithigh', App.setHigh);
    $(document).on('click', '#submitlow', App.setLow);
    $(document).on('click', '#calcrew', App.calcrew);
    $(document).on('click', '#rstartgame', App.exitgame);
    $(document).on('click', '#nxturn', App.gameState);
    $(document).on('click', '#newgame', App.newgame);
  }
};



$(function () {
  $(window).load(function () {
    App.init();
  });
});