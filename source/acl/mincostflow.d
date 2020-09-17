module acl.mincostflow;

// --- mincostflow ---

struct MCFGraph(Cap, Cost)
{
    import std.typecons : Tuple;

public:
    this(int n)
    {
        _n = n;
        g = new _edge[][](n);
    }

    int addEdge(int from, int to, Cap cap, Cost cost)
    {
        assert(0 <= from && from < _n);
        assert(0 <= to && to < _n);
        int m = cast(int) pos.length;
        pos ~= Tuple!(int, int)(from, cast(int) g[from].length);
        g[from] ~= _edge(to, (cast(int) g[to].length), cap, cost);
        g[to] ~= _edge(from, (cast(int) g[from].length) - 1, 0, -cost);
        return m;
    }

    struct edge
    {
        int from, to;
        Cap cap, flow;
        Cost cost;
    }

    edge getEdge(int i)
    {
        int m = cast(int) pos.length;
        assert(0 <= i && i < m);
        auto _e = g[pos[i][0]][pos[i][1]];
        auto _re = g[_e.to][_e.rev];
        return edge(pos[i][0], _e.to, _e.cap + _re.cap, _re.cap, _e.cost);
    }

    edge[] edges()
    {
        int m = cast(int) pos.length;
        auto result = new edge[](m);
        foreach (i; 0 .. m)
            result[i] = getEdge(i);
        return result;
    }

    Tuple!(Cap, Cost) flow(int s, int t)
    {
        return flow(s, t, Cap.max);
    }

    Tuple!(Cap, Cost) flow(int s, int t, Cap flow_limit)
    {
        return slope(s, t, flow_limit)[$ - 1];
    }

    Tuple!(Cap, Cost)[] slope(int s, int t)
    {
        return slope(s, t, Cap.max);
    }

    Tuple!(Cap, Cost)[] slope(int s, int t, Cap flow_limit)
    {
        import std.container : Array, BinaryHeap;
        import std.algorithm : min;

        assert(0 <= s && s < _n);
        assert(0 <= t && t < _n);
        assert(s != t);
        auto dual = new Cost[](_n);
        auto dist = new Cost[](_n);
        auto pv = new int[](_n);
        auto pe = new int[](_n);
        auto vis = new bool[](_n);
        bool dualRef()
        {
            dist[] = Cost.max;
            pv[] = -1;
            pe[] = -1;
            vis[] = false;
            struct Q
            {
                Cost key;
                int to;
                int opCmp(const Q other) const
                {
                    if (key == other.key)
                        return 0;
                    return key > other.key ? -1 : 1;
                }
            }

            BinaryHeap!(Array!Q) que;
            dist[s] = 0;
            que.insert(Q(0, s));
            while (!que.empty)
            {
                int v = que.front.to;
                que.removeFront();
                if (vis[v])
                    continue;
                vis[v] = true;
                if (v == t)
                    break;
                foreach (i; 0 .. cast(int) g[v].length)
                {
                    auto e = g[v][i];
                    if (vis[e.to] || !e.cap)
                        continue;
                    Cost cost = e.cost - dual[e.to] + dual[v];
                    if (dist[e.to] - dist[v] > cost)
                    {
                        dist[e.to] = dist[v] + cost;
                        pv[e.to] = v;
                        pe[e.to] = i;
                        que.insert(Q(dist[e.to], e.to));
                    }
                }
            }
            if (!vis[t])
                return false;
            foreach (v; 0 .. _n)
            {
                if (!vis[v])
                    continue;
                dual[v] -= dist[t] - dist[v];
            }
            return true;
        }

        Cap flow = 0;
        Cost cost = 0, prev_cost = -1;
        Tuple!(Cap, Cost)[] result;
        result ~= Tuple!(Cap, Cost)(flow, cost);
        while (flow < flow_limit)
        {
            if (!dualRef())
                break;
            Cap c = flow_limit - flow;
            for (int v = t; v != s; v = pv[v])
                c = min(c, g[pv[v]][pe[v]].cap);
            for (int v = t; v != s; v = pv[v])
            {
                g[pv[v]][pe[v]].cap -= c;
                g[v][g[pv[v]][pe[v]].rev].cap += c;
            }
            Cost d = -dual[s];
            flow += c;
            cost += c * d;
            if (prev_cost == d)
                result.length--;
            result ~= Tuple!(Cap, Cost)(flow, cost);
            prev_cost = cost;
        }
        return result;
    }

private:
    int _n;
    struct _edge
    {
        int to, rev;
        Cap cap;
        Cost cost;
    }

    Tuple!(int, int)[] pos;
    _edge[][] g;
}
