pragma solidity >=0.4.21 <0.6.0;
import "./AddressArray.sol";

contract LiquidDemocracy{

  using AddressArray for address[];

  address public owner;

  mapping (address => uint) public vote_weight;
  mapping (address => address) public v_to_parent;
  mapping (address => address[]) public v_to_children;
  uint public voter_count;

  // add by hzx
  // a data structure to detect delagation relation ship among addresses.
  LinkCutTree lct;

  event Delegate(address from, address to, uint height);
  event Undelegate(address from, address to, uint height);
  event SetWeight(address addr, uint weight, uint height);
  event CreateVote(address addr, uint height);

  constructor() public{
    owner = msg.sender;
    voter_count = 0;
    // alert by hzx
    // initialize lct.
    lct = LinkCutTree();
  }

  modifier isOwner{
    if(msg.sender == owner) _;
  }

  function setWeight(address addr, uint weight) public isOwner{
    require(weight > 0);
    require(addr != address(0x0));
    vote_weight[addr] = weight;
    voter_count ++;

    // alert by hzx 
    // add a new address.
    lct.add_address(addr);

    emit SetWeight(addr, weight, block.number);
  }

  function check_circle(address _from, address _to) internal view returns(bool){
    return false;
  }

  function delegate(address _to) public {
    require(_to != msg.sender, "cannot be self");
    require(vote_weight[msg.sender] != 0, "no sender");
    require(vote_weight[_to] != 0, "no _to");
    // bool has_circle = check_circle(msg.sender, _to);
    // require(!has_circle, "cannot be circle");

    // alert by hzx
    // cut edge from msg.sender to _to.
    address old = v_to_parent[msg.sender];
    if(odl != address(0x0)){
      lct.undelegate(msg.sender, _to);
      address[] storage children = v_to_children[old];
      children.remove(msg.sender);
    }
    // link msg.sender to _to
    bool delegate_res = lct.delegate(msg.sender, _to);
    require(delegate_res, "cannot be circle");
    v_to_parent[msg.sender] = _to;
    v_to_children[_to].push(msg.sender);

    emit Delegate(msg.sender, _to, block.number);
  }

  function undelegate() public pure{
    require(false, "future work");
  }

  function getDelegator(address addr, uint height) public view returns(address ){
    //require(v_to_parent[addr] != address(0x0), "no parent");
    return v_to_parent[addr];
  }

  function getDelegatee(address addr, uint height) public view returns (address [] memory){
    return v_to_children[addr];
  }

  function getWeight(address addr, uint height) public view returns(uint) {
    return vote_weight[addr];
  }
  function getVoterCount(uint height) public view returns(uint){
    return voter_count;
  }
}
