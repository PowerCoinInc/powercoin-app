pragma solidity ^0.4.8;

contract PowerCoin {

    /******** Mappings ********/

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // An array of all the frozen accounts.
    mapping (address => bool) public frozenAccount;


    /******** Public Variables *********/

    string public standard = 'Token 0.1';
    address public owner = 0x0D9Af3566506F04DEa3eD3D7465068F718462806;
    //address public owner = 0xf6862A9749346DA65CA2163A485FE2b558E66fB2; //TestNet
    string public tokenName = 'PowerCoin';
    string public symbol = 'MWh';
    uint8 public decimalUnits = 6;
    uint256 public totalSupply = 50000000000000;
    uint256 public sellPrice;
    uint256 public buyPrice;

    // Initializes contract with initial supply tokens to the creator of the contract
    function PowerCoin(address owner, uint256 initialSupply, string name, uint8 decimals, string tokenSymbol) {
        owner = owner;      // Sets the owner as specified (if centralMinter is not specified the owner is msg.sender)
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
        totalSupply = initialSupply;                        //
    }

    // Send PowerCoin
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[msg.sender]) throw;                // Check if frozen
        if (frozenAccount[_to]) throw;                // Check if frozen
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        return true;
    }

    // Attempt to Receive PowerCoin
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[_from]) throw;                        // Check if frozen
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    // Make more PowerCoin
    function mintPowerCoin(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;

        PowerCoinAlert(block.timestamp, msg.sender, target, mintedAmount, "Attempt to mint more ");
    }

    // Freeze an inactive or abusive account
    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    // Set the price of a Megawatt Hour
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /******** Modifers ********/
    modifier onlyOwner {
        if (msg.sender != owner) {
            PowerCoinAlert(block.timestamp, msg.sender, owner, 0, "Error: Unauthorized Access");
        }
        _;
    }

    /******** Events ********/
    event PowerCoinAlert (uint eventTimeStamp,
                            address indexed callingAddress,
                            address indexed meterKey,
                            uint indexed currentCoinValue,
                            bytes32 description);

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds (address target, bool frozen);

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}