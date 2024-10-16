/**
 *Submitted for verification at testnet.bscscan.com on 2024-10-12
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: pro/gasnefi.sol


pragma solidity ^0.8.17;


contract NefiToken is IERC20, ReentrancyGuard {
    string private constant _name = "NefiToken";
    string private constant _symbol = "NEFI";
    uint8 private constant _decimals = 18;
    uint256 private constant MAX_SUPPLY = 7000000 * 1e18; // 7 million with 18 decimals
    uint256 private _totalSupply;
    // Token mappings
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    // Contract-related properties
    IERC20 public immutable deodToken;
    address public defaultReferrer = 0x1234567890123456789012345678901234567890;
    address public nullAddress = 0x000000000000000000000000000000000000dEaD;
    // Staking and circulation properties
    uint256 public totalDeodStaked;
    uint256 public circulatingNefiSupply;
    // Referral properties
    uint256[6] public referralRewards = [7, 1, 1, 1, 1, 1];
    mapping(address => address) public referral;
    mapping(address => uint256) public referralRewardsAccumulated;
    mapping(address => uint256) public downlineCount;
    // User tracking
    mapping(address => address[]) public referrals; // Mapping to store the direct referrals of each address
    mapping(address => uint256) public deodStaked;
    mapping(address => uint256) public unclaimedNefiTokens;
    mapping(address => uint256) public claimedNefiTokens;
    // Transaction records
    uint256 public nextBuyId;
    uint256 public nextSellId;
    mapping(uint256 => BuyRecord) public buyHistory;
    mapping(uint256 => SellRecord) public sellHistory;
    mapping(address => TransactionRecord[]) public buyRecordsByUser;
    mapping(address => TransactionRecord[]) public sellRecordsByUser;
    mapping(address => uint256) private lastActionTime;
    uint256 private actionCooldown = 1 minutes; // Cooldown period
    // Events
    event NefiTokenBuy(address user, uint256 nefiBuy, uint256 currentNefiPrice);
    event NefiTokenSold(
        address user,
        uint256 nefiSold,
        uint256 currentNefiPrice,
        uint256 deodReturned
    );
    event TokensClaimed(address user, uint256 amount);
    event ReferralRegistered(address user, address referrer);
    // Modifier to check if the cooldown period has passed for a user
    modifier cooldownPassed(string memory errorMessage) {
        require(
            block.timestamp >= lastActionTime[msg.sender] + actionCooldown,
            errorMessage
        );
        _;
    }
    // Modifier to check User can't Re-set the referer ReciprocalReferral.
    modifier noReciprocalReferral(address _referrer) {
        require(
            referral[msg.sender] != _referrer,
            "Cannot set reciprocal referrer"
        );
        _;
    }
    // Structs
    struct BuyRecord {
        address buyer;
        uint256 amountInDeod;
        uint256 userAmount;
        address referrer;
        uint256 timestamp;
        uint256 buyId;
    }
    struct SellRecord {
        address seller;
        uint256 amountInNefi;
        uint256 deodReturned;
        uint256 timestamp;
        uint256 sellId;
    }
    struct TransactionRecord {
        uint256 amount;
        uint256 timestamp;
        uint256 transactionId;
    }
    constructor(address _deodToken) {
        deodToken = IERC20(_deodToken);
    }
    // ERC20 Standard Functions
    function name() public view virtual returns (string memory) {
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        require(
            _allowances[sender][msg.sender] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        // Instead of using SafeMath, Solidity's built-in checks will handle overflows and underflows
        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        // Ensure the account has enough balance before proceeding with the burn
        require(
            _balances[account] >= amount,
            "ERC20: burn amount exceeds balance"
        );
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function isContract(address addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        return (size > 0);
    }
    /**
     * @dev Allows users to claim their Nefi tokens based on their eligibility.
     * Mints the specified amount of Nefi tokens and transfers them to the user's account.
     * @param amount The amount of tokens the user is eligible to claim.
     */
    function claimTokens(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot claim 0 Nefi");
        require (!isContract(msg.sender), "Caller must be an EOA");
        require(_totalSupply + amount <= MAX_SUPPLY, "Max supply exceeded"); // Check against max supply
        require(
            unclaimedNefiTokens[msg.sender] >= amount,
            "Not enough unclaimed tokens"
        );
        unclaimedNefiTokens[msg.sender] -= amount;
        claimedNefiTokens[msg.sender] += amount;
        circulatingNefiSupply -= amount;
        _mint(address(this), amount);
        _transfer(address(this), msg.sender, amount);
        emit TokensClaimed(msg.sender, amount);
    }
    /**
     * @dev Facilitates the purchase of Nefi Tokens using DEOD tokens.
     * Transfers DEOD tokens to the contract, calculates and mints Nefi tokens,
     * and distributes referral rewards.
     * @param amountIn The amount of DEOD tokens to stake.
     */
    function BuyNefi(uint256 amountIn)
        external
        nonReentrant
        cooldownPassed("Cooldown for buying Nefi tokens not passed yet")
    {
        require(
            amountIn > 0 && amountIn <= 10000000000000000000000,
            "Amount must be greater than 0 and less than or equal to 10000"
        );
        require (!isContract(msg.sender), "Caller must be an EOA");
        uint256 currentPrice = getCurrentNefiPrice();
        // Transfer the DEOD token to Null Address
        uint256 nullAddressAmt = (amountIn * 3) / 100;
        uint256 AmtIn = amountIn - nullAddressAmt;
        totalDeodStaked += AmtIn;
        uint256 nefiToMint = (amountIn * 1e18) / currentPrice;
        uint256 userAmount = (nefiToMint * 70) / 100;
        uint256 deductAmt = (nefiToMint * 18) / 100;
        uint256 referralAmount = (nefiToMint * 12) / 100;
        circulatingNefiSupply += (userAmount + referralAmount);
        deodStaked[msg.sender] += amountIn;
        unclaimedNefiTokens[msg.sender] += userAmount;
        address referrer = referral[msg.sender];
        if (referrer == address(0)) {
            referrer = defaultReferrer;
        }
        distributeReferralRewards(referrer, referralAmount, nefiToMint);
        lastActionTime[msg.sender] = block.timestamp;
        uint256 transactionId = nextBuyId++;
        buyHistory[nextBuyId] = BuyRecord({
            buyer: msg.sender,
            amountInDeod: amountIn,
            userAmount: userAmount,
            referrer: referrer,
            timestamp: block.timestamp,
            buyId: nextBuyId
        });
        buyRecordsByUser[msg.sender].push(
            TransactionRecord({
                amount: amountIn,
                timestamp: block.timestamp,
                transactionId: transactionId
            })
        );
        require(
            deodToken.transferFrom(msg.sender, address(this), amountIn),
            "Token transfer failed"
        );
        require(
            deodToken.transfer(nullAddress, nullAddressAmt),
            "Token transfer failed"
        );
        emit NefiTokenBuy(msg.sender, userAmount, currentPrice);
    }
    /**
     * @dev Allows users to sell their Nefi tokens in exchange for DEOD tokens.
     * Calculates the DEOD tokens to be returned to the user after applying a platform fee.
     * @param amountIn The amount of Nefi tokens to sell.
     */
    function sellNefi(uint256 amountIn)
        external
        nonReentrant
        cooldownPassed("Cooldown for selling Nefi tokens not passed yet")
    {
        require(amountIn > 0, "Amount must be greater than 0");
        uint256 currentPrice = getCurrentNefiPrice();
        require(
            unclaimedNefiTokens[msg.sender] >= amountIn,
            "Not enough unclaimed tokens to sell"
        );
        require (!isContract(msg.sender), "Caller must be an EOA");
       
        uint256 getDeod = (amountIn * currentPrice) / 1e18;
        uint256 fee = (getDeod * 15) / 100;
        uint256 userGetDeod = getDeod - fee;
        uint256 maxDeodAllowed = deodStaked[msg.sender] * 2;
        require(
            userGetDeod <= maxDeodAllowed,
            "Cannot withdraw more than 2x of staked DEOD"
        );
        unclaimedNefiTokens[msg.sender] -= amountIn;
        circulatingNefiSupply -= amountIn;
        totalDeodStaked -= userGetDeod;
        lastActionTime[msg.sender] = block.timestamp;
        require(
            deodToken.balanceOf(address(this)) >= userGetDeod,
            "Not enough DEOD in contract"
        );
        uint256 transactionId = nextSellId++;
        sellHistory[nextSellId] = SellRecord({
            seller: msg.sender,
            amountInNefi: amountIn,
            deodReturned: userGetDeod,
            timestamp: block.timestamp,
            sellId: nextSellId
        });
        sellRecordsByUser[msg.sender].push(
            TransactionRecord({
                amount: amountIn,
                timestamp: block.timestamp,
                transactionId: transactionId
            })
        );
        require(
            deodToken.transfer(msg.sender, userGetDeod),
            "Token transfer failed"
        );
        emit NefiTokenSold(msg.sender, amountIn, currentPrice, userGetDeod);
    }
    function getCurrentNefiPrice() public view returns (uint256) {
        if (circulatingNefiSupply == 0) {
            return 1e18; // Initial price 1:1 (1 DEOD = 1 MAGIC)
        }
        return (totalDeodStaked * 1e18) / circulatingNefiSupply;
    }
    /**
     * @dev Function to get the direct referrals of an address
     */
    function getDirectReferrals(address _referrer)
        public
        view
        returns (address[] memory)
    {
        return referrals[_referrer];
    }
    /**
     * @dev Registers a user with a referrer for the referral system.
     * Prevents setting a reciprocal referrer to avoid circular referral issues.
     * @param referrer The address of the referrer to be registered.
     */
    function Register(address referrer)
        external
        noReciprocalReferral(referrer)
    {
        require(!isContract(referrer), "Contracts cannot be referrers");
        require(referral[msg.sender] == address(0), "Referrer already set");
        require(referrer != msg.sender, "Self-referral prohibited");
        referral[msg.sender] = referrer;
        referrals[referrer].push(msg.sender);
        downlineCount[referrer] += 1;
        emit ReferralRegistered(msg.sender, referrer);
    }
    /**
     * @dev Distributes referral rewards to users based on the referral program.
     */
    function distributeReferralRewards(
        address referrer,
        uint256 totalReferralAmount,
        uint256 nefiToMint
    ) internal {
        address currentReferrer = referrer;
        uint256 remainingAmount = totalReferralAmount;
        for (uint256 i = 0; i < 6; i++) {
            if (currentReferrer == address(0)) {
                break;
            }
            uint256 refReward = (nefiToMint * referralRewards[i]) / 100;
            remainingAmount -= refReward;
            unclaimedNefiTokens[currentReferrer] += refReward;
            referralRewardsAccumulated[currentReferrer] += refReward;
            currentReferrer = referral[currentReferrer];
        }
        if (remainingAmount > 0) {
            unclaimedNefiTokens[defaultReferrer] += remainingAmount;
            referralRewardsAccumulated[defaultReferrer] += remainingAmount;
        }
    }
}