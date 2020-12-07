pragma solidity >=0.4.21 <0.6.0;

contract LinkCutTree {
    mapping(address => uint32) public v_to_number; // node’s address to number
    uint8[] public vtag;
    uint32[] public vfather;
    uint32[] public vchild;
    uint32 public node_count;
    uint[] weight;

    constructor() public {
        node_count = 0;
    }

    // _from delegates its voting power to _to
    function delegate(address _from, address _to) external returns(bool){
        bool has_path = is_connected(_from, _to);
        require(!has_path, "cannot be circle");
        uint32 num_from = add_address(_from);
        uint32 num_to = add_address(_to);
        makeroot(num_to);
        vfather[num_to] = num_from;
        return true;
    }

    // _from delegates its voting power to _to
    function undelegate(address _from, address _to) external returns(bool){
        uint32 x = add_address(_from);
        uint32 y = add_address(_to);
        makeroot(y);
        // 如果y和x不在一棵树上，或者x和y之间不邻接(x的父亲不是y 或者x有左儿子)，不进行cut
        bool connected = findRoot(x) != y || vfather[x] != y || vchild[x][0];
        require(connected, "have no delegation relationship");
        vfather[x] = vchild[y][1] = 0;
        update(y);
        return true;
    }

    // check wheter there is a path between _from and to
    function is_connected(address _from, address _to) internal retruns(bool){
        uint32 from_number = v_to_number[_from];
        bool ans = false;
        if(from_number == 0){
            return ans;
        }
        uint32 to_number = v_to_number[_to];
        if(to_number == 0){
            return ans;
        }
        if(findroot(from_number) == findroot(to_number)){
            ans =  true;
        }
        return ans;
    }

        // add a new address
    function add_address(address addr) internal returns(uint32){
        if (v_to_number[addr] == 0) {
            ++node_count;
            v_to_number[addr] = node_count;
            vfather.push(0);
            vchild.push(0);
            vtag.push(0);
            ans = true;
        }
        return v_to_number[addr];
    }

    // judge x is a left child or a right child in a splay.
    function getch(uint32 x) internal view returns (uint32) {
        if (vchild[vfather[x]][1] == x) return 1;
        return 0;
    }

    // judge wheter x is the root of its splay.
    function isroot(uint32 x) internal view returns(bool){
        return vchild[vfather[x]][0] != x && vchild[vfather[x]][1] != x;
    }

    // transmit information from x to its children.
    function pushdown(uint32 x)internal {
        if(vtag[x] == 1){
            if (vchild[x][0]){
                uint32 temp = vchild[vchild[x][0]][0];
                vchild[vchild[x][0]][0] = vchild[vchild[x][0]][1];
                vchild[vchild[x][0]][1] = temp;
                vtag[vchild[x][0]] ^= 1;
            }
            if (vchild[x][1]){
                uint32 temp = vchild[vchild[x][1]][0];
                vchild[vchild[x][1]][0] = vchild[vchild[x][1]][1];
                vchild[vchild[x][1]][1] = temp;
                vtag[vchild[x][1]] ^= 1;
            }
            vtag[x] = 0;
        }
    }

    // update info from its corresponding splay root to x.
    function update(uint32 x) internal {
        if(!isroot(x))
            update(vfather[x]);
        pushdown(x);
    }

    // rotate a node x
    function rotate(uint32 x)internal{
        uint32 y = vfather[x];
        uint32 z = vfather[y];
        uint32 chx = getch(x);
        utin32 chy = getch(y);
        vfather[x] = z;
        if (!isroot(y))
            vchild[z][chy] = x;
        vchild[y][chx] = vchild[x][chx ^ 1];
        vfather[vchild[x][chx ^ 1]] = y;
        vchild[x][chx ^ 1] = y;
        vfather[y] = x;
    }

    // rotate x to be the root of its splay
    function splay(uint32 x) internal{
        // update information in the path which is from the root to x.
        update(x);
        int f;
        // while 保证x一定可以旋转到根节点位置
        while (!isroot(x))
        {
            f = vfather[x];
            if (!isroot(f))
                rotate(getch(x) == getch(f) ? f : x);
            rotate(x);
        }
    }

    // create a path from the root to x.
    function access(uint32 x) internal{
        // 将最后一个点的右儿子变为0，即变为虚边
        uint32 son = 0;
        while(x){
            // 将x转换为当前树的树根
            splay(x);
            // 将x的右儿子设置为前一棵splay树的树根
            vchild[x][1] = son;
            // x的孩子发生变化，上传信息
            pushup(x);
            // son 保存当前splay树树根，x是其父节点
            x = vfather[son = x];
        }
    }

    // 将原来的树中x节点作为根节点
    function makeroot(uint32 x) internal
    {
        access(x);
        // splay(x) 之后x在这个树的最右下角 
        splay(x);
        // 交换x的左孩子节点和右孩子节点
        swap(vchild[x][0], vchild[x][1]);
        // 进行懒人标记，不再递归的进行翻转
        vtag[x] ^= 1;
    }

    // 寻找x节点在原树的根节点
    function findRoot(uint32 x) internal returns (uint32)
    {
        access(x);
        splay(x);
        // 最左边的一定是根节点
        while (vchild[x][0])
        {
            // 下传懒标记
            pushdown(x);
            x = vchild[x][0];
        }
        // 对根节点进行splay，保证时间复杂度
        splay(x);
        return x;
    }

    // 把x到y的路径拆成一棵方便的Splay树
    function split(uint32 x, uint32 y) internal
    {
        // 如果x和y根本不在同一条路径上，则跳过
        if (findRoot(x) != findRoot(y))
            return;
        makeroot(x);
        access(y);
        splay(y);
    }
}
