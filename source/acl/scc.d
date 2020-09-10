module scc;

import acl.internal_scc;

// --- scc ---

struct SccGraph
{
    this(int n)
    {
        internal = SccGraphImpl(n);
    }

    void addEdge(int from, int to)
    {
        int n = internal.numVerticles();
        assert(0 <= from && from < n);
        assert(0 <= to && to < n);
        internal.addEdge(from, to);
    }

    int[][] scc()
    {
        return internal.scc();
    }

private:
    SccGraphImpl internal;
}
