module acl.mincostflow;

unittest
{
    MCFGraph!(int, int) g1;
    auto g2 = MCFGraph!(int, int)(0);
}

unittest
{
    import std.typecons : Tuple;

    auto g = MCFGraph!(int, int)(4);
    g.addEdge(0, 1, 1, 1);
    g.addEdge(0, 2, 1, 1);
    g.addEdge(1, 3, 1, 1);
    g.addEdge(2, 3, 1, 1);
    g.addEdge(1, 2, 1, 1);
    auto expect = [Tuple!(int, int)(0, 0), Tuple!(int, int)(2, 4)];
    assert(expect == g.slope(0, 3, 10));

    assert(MCFGraph!(int, int).Edge(0, 1, 1, 1, 1) == g.getEdge(0));
    assert(MCFGraph!(int, int).Edge(0, 2, 1, 1, 1) == g.getEdge(1));
    assert(MCFGraph!(int, int).Edge(1, 3, 1, 1, 1) == g.getEdge(2));
    assert(MCFGraph!(int, int).Edge(2, 3, 1, 1, 1) == g.getEdge(3));
    assert(MCFGraph!(int, int).Edge(1, 2, 1, 0, 1) == g.getEdge(4));
}

unittest
{
    import std.typecons : Tuple;
    {
        auto g = MCFGraph!(int, int)(2);
        g.addEdge(0, 1, 1, 2);
        assert(Tuple!(int, int)(1, 2) == g.flow(0, 1));
    }
    {
        auto g = MCFGraph!(int, int)(2);
        g.addEdge(0, 1, 1, 2);
        auto expect = [Tuple!(int, int)(0, 0), Tuple!(int, int)(1, 2)];
        assert(expect == g.slope(0, 1));
    }
}

unittest
{
    MCFGraph!(int, int) g;
    g = MCFGraph!(int, int)(10);
}

unittest
{
    import std.exception : assertThrown;

    auto g = MCFGraph!(int, int)(10);
    assertThrown!Error(g.slope(-1, 3));
    assertThrown!Error(g.slope(3, 3));
}

unittest
{
    import std.typecons : Tuple;

    auto g = MCFGraph!(int, int)(3);
    assert(0 == g.addEdge(0, 1, 1, 1));
    assert(1 == g.addEdge(1, 2, 1, 0));
    assert(2 == g.addEdge(0, 2, 2, 1));
    auto expected = [Tuple!(int, int)(0, 0), Tuple!(int, int)(3, 3)];
    assert(expected == g.slope(0, 2));
}

unittest
{
    import std.exception : assertThrown;

    auto g = MCFGraph!(int, int)(2);
    assertThrown!Error(g.addEdge(0, 0, -1, 0));
    assertThrown!Error(g.addEdge(0, 0, 0, -1));
}

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
        assert(0 <= cap);
        assert(0 <= cost);
        int m = cast(int) pos.length;
        pos ~= Tuple!(int, int)(from, cast(int) g[from].length);
        int from_id = cast(int) g[from].length;
        int to_id = cast(int) g[to].length;
        if (from == to)
            to_id++;
        g[from] ~= _edge(to, to_id, cap, cost);
        g[to] ~= _edge(from, from_id, 0, -cost);
        // g[from] ~= _edge(to, (cast(int) g[to].length), cap, cost);
        // g[to] ~= _edge(from, (cast(int) g[from].length) - 1, 0, -cost);
        return m;
    }

    struct Edge
    {
        int from, to;
        Cap cap, flow;
        Cost cost;
    }

    Edge getEdge(int i)
    {
        int m = cast(int) pos.length;
        assert(0 <= i && i < m);
        auto _e = g[pos[i][0]][pos[i][1]];
        auto _re = g[_e.to][_e.rev];
        return Edge(pos[i][0], _e.to, _e.cap + _re.cap, _re.cap, _e.cost);
    }

    Edge[] edges()
    {
        int m = cast(int) pos.length;
        auto result = new Edge[](m);
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
        Cost cost = 0, prev_cost_per_flow = -1;
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
            if (prev_cost_per_flow == d)
                result.length--;
            result ~= Tuple!(Cap, Cost)(flow, cost);
            prev_cost_per_flow = d;
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
