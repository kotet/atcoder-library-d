module acl.twosat;

import acl.internal_scc;

unittest
{
    TwoSat ts0;
    assert(ts0.satisfiable());
    assert([] == ts0.answer());
    auto ts1 = TwoSat(0);
    assert(ts1.satisfiable());
    assert([] == ts1.answer());
}

unittest
{
    {
        auto ts = TwoSat(1);
        ts.addClause(0, true, 0, true);
        ts.addClause(0, false, 0, false);
        assert(!ts.satisfiable());
    }
    {
        auto ts = TwoSat(1);
        ts.addClause(0, true, 0, true);
        assert(ts.satisfiable());
        assert([true] == ts.answer());
    }
    {
        auto ts = TwoSat(1);
        ts.addClause(0, false, 0, false);
        assert(ts.satisfiable());
        assert([false] == ts.answer());
    }
}

unittest
{
    TwoSat ts;
    ts = TwoSat(10);
}

// --- twosat ---

struct TwoSat
{
public:
    this(int n) @safe nothrow
    {
        _n = n;
        _answer = new bool[](n);
        scc = SccGraphImpl(2 * n + 2);
    }

    void addClause(int i, bool f, int j, bool g) @safe nothrow
    {
        assert(0 <= i && i < _n);
        assert(0 <= j && j < _n);
        scc.addEdge(2 * i + (f ? 0 : 1), 2 * j + (g ? 1 : 0));
        scc.addEdge(2 * j + (g ? 0 : 1), 2 * i + (f ? 1 : 0));
    }

    bool satisfiable() @safe nothrow
    {
        auto id = scc.sccIds()[1];
        foreach (i; 0 .. _n)
        {
            if (id[2 * i] == id[2 * i + 1])
                return false;
            _answer[i] = id[2 * i] < id[2 * i + 1];
        }
        return true;
    }

    bool[] answer() @safe nothrow @nogc
    {
        return _answer;
    }

private:
    int _n;
    bool[] _answer;
    SccGraphImpl scc;
}
