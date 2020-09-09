module acl.maxflow;

// --- maxflow ---

struct MFGraph(Cap)
{
    import std.typecons : Tuple;

public:
    this(int n)
    {
        _n = n;
        g = new _edge[][](n);
    }

    int addEdge(int from, int to, Cap cap)
    {
        assert(0 <= from && from < _n);
        assert(0 <= to && to < _n);
        assert(0 <= cap);
        int m = cast(int) pos.length;
        pos ~= Tuple!(int, int)(from, cast(int)(g[from].length));
        g[from] ~= _edge(to, cast(int)(g[to].length), cap);
        g[to] ~= _edge(from, cast(int)(g[from].length) - 1, 0);
        return m;
    }

    struct edge
    {
        int from, to;
        Cap cap, flow;
    }

    edge getEdge(int i)
    {
        int m = cast(int)(pos.length);
        assert(0 <= i && i < m);
        auto _e = g[pos[i][0]][pos[i][1]];
        auto _re = g[_e.to][_e.rev];
        return edge(pos[i][0], _e.to, _e.cap + _re.cap, _re.cap);
    }

    edge[] edges()
    {
        int m = cast(int)(pos.length);
        edge[] result;
        foreach (i; 0 .. m)
            result ~= getEdge(i);
        return result;
    }

    void changeEdge(int i, Cap new_cap, Cap new_flow)
    {
        int m = cast(int)(pos.length);
        assert(0 <= i && i < m);
        assert(0 <= new_flow && new_flow <= new_cap);
        auto _e = &g[pos[i][0]][pos[i][1]];
        auto _re = &g[_e.to][_e.rev];
        _e.cap = new_cap - new_flow;
        _re.cap = new_flow;
    }

    Cap flow(int s, int t)
    {
        return flow(s, t, Cap.max);
    }

    Cap flow(int s, int t, Cap flow_limit)
    {
        import std.container : DList;
        import std.algorithm : min;

        assert(0 <= s && s < _n);
        assert(0 <= t && t < _n);

        auto level = new int[](_n), iter = new int[](_n);
        DList!int que;

        void bfs()
        {
            level[] = -1;
            level[s] = 0;
            que.clear();
            que.insertBack(s);
            while (!que.empty)
            {
                int v = que.front;
                que.removeFront();
                foreach (e; g[v])
                {
                    if (e.cap == 0 || level[e.to] >= 0)
                        continue;
                    level[e.to] = level[v] + 1;
                    if (e.to == t)
                        return;
                    que.insertBack(e.to);
                }
            }
        }

        Cap dfs(int v, Cap up)
        {
            if (v == s)
                return up;
            Cap res = 0;
            int level_v = level[v];
            for (; iter[v] < cast(int)(g[v].length); iter[v]++)
            {
                auto i = iter[v];
                auto e = g[v][i];
                if (level_v <= level[e.to] || g[e.to][e.rev].cap == 0)
                    continue;
                Cap d = dfs(e.to, min(up - res, g[e.to][e.rev].cap));
                if (d <= 0)
                    continue;
                g[v][i].cap += d;
                g[e.to][e.rev].cap -= d;
                res += d;
                if (res == up)
                    break;
            }
            return res;
        }

        Cap flow = 0;
        while (flow < flow_limit)
        {
            bfs();
            if (level[t] == -1)
                break;
            iter[] = 0;
            while (flow < flow_limit)
            {
                Cap f = dfs(t, flow_limit - flow);
                if (!f)
                    break;
                flow += f;
            }
        }
        return flow;
    }

    bool[] minCut(int s)
    {
        import std.container : DList;

        auto visited = new bool[](_n);
        DList!int que;
        que.insertBack(s);
        while (!que.empty)
        {
            int p = que.front;
            que.removeFront();
            visited[p] = true;
            foreach (e; g[p])
            {
                if (e.cap && !visited[e.to])
                {
                    visited[e.to] = true;
                    que.insertBack(e.to);
                }
            }
        }
        return visited;
    }

private:
    struct _edge
    {
        int to, rev;
        Cap cap;
    }

    int _n;
    Tuple!(int, int)[] pos;
    _edge[][] g;
}
