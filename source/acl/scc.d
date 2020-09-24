module scc;

import acl.internal_scc;

unittest
{
    SccGraph graph0;
    assert([] == graph0.scc());
    auto graph1 = SccGraph(0);
    assert([] == graph1.scc());
}

unittest
{
    SccGraph graph;
    graph = SccGraph(10);
}

unittest
{
    auto graph = SccGraph(2);
    graph.addEdge(0, 1);
    graph.addEdge(1, 0);
    auto scc = graph.scc();
    assert(1 == scc.length);
}

unittest
{
    auto graph = SccGraph(2);
    graph.addEdge(0, 0);
    graph.addEdge(0, 0);
    graph.addEdge(1, 1);
    auto scc = graph.scc();
    assert(2 == scc.length);
}

unittest
{
    import std.exception;

    auto graph = SccGraph(2);
    assertThrown!Error(graph.addEdge(0, 10));
}

// --- scc ---

struct SccGraph
{
    this(int n) @safe nothrow
    {
        internal = SccGraphImpl(n);
    }

    void addEdge(int from, int to) @safe nothrow
    {
        int n = internal.numVerticles();
        assert(0 <= from && from < n);
        assert(0 <= to && to < n);
        internal.addEdge(from, to);
    }

    int[][] scc() @safe nothrow
    {
        return internal.scc();
    }

private:
    SccGraphImpl internal;
}
