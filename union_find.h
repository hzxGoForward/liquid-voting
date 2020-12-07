#include <vector>
using namespace std;

class UnionFind{

    vector<int> rank, parent;
public:
    UnionFind(const int sz){
        for (int i = 0; i < sz; ++i){
            parent[i] = i;
            rank[i] = i;
        }
    }

    int size(){
        return parent.size();
    }

    bool isConnected(int p, int q){
        return find(p) == find(q);
    }

    void unionElements(int p, int q){
        int pRoot = find(p);
        int qRoot = find(q);
        if(pRoot == qRoot)
            return;
        if(rank[pRoot] < rank[qRoot])
            parent[pRoot] = qRoot;
        else if(rank[pRoot] > rank[qRoot])
            parent[qRoot] = pRoot;
        else{
            parent[pRoot] = qRoot;
            rank[qRoot] += 1;
        }
    }

private:

    int find(int p){
        while(p != parent[p]){
            parent[p] = parent[parent[p]];
            p = parent[p];
        }
        return p;
    }

};