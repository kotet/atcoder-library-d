module acl.dsu;

unittest
{
    auto uf = Dsu(0);
    assert([] == uf.groups());
}

unittest
{
    Dsu uf;
    assert([] == uf.groups());
}

unittest
{
    Dsu uf;
    uf = Dsu(10);
}

unittest
{
    auto uf = Dsu(2);
    assert(!uf.same(0, 1));
    int x = uf.merge(0, 1);
    assert(x == uf.leader(0));
    assert(x == uf.leader(1));
    assert(uf.same(0, 1));
    assert(2 == uf.size(0));
}

unittest
{
    int n = 500_000;
    auto uf = Dsu(n);
    foreach (i; 0 .. n - 1)
        uf.merge(i, i + 1);
    assert(n == uf.size(0));
    assert(1 == uf.groups().length);
}

unittest
{
    int n = 500_000;
    auto uf = Dsu(n);
    foreach_reverse (i; 0 .. n - 2 + 1)
        uf.merge(i, i + 1);
    assert(n == uf.size(0));
    assert(1 == uf.groups().length);
}

// --- dsu ---

struct Dsu
{
public:
    this(long n) @safe nothrow
    {
        _n = cast(int) n, parent_or_size = new int[](n);
        parent_or_size[] = -1;
    }

    int merge(long a, long b) @safe nothrow @nogc
    {
        assert(0 <= a && a < _n);
        assert(0 <= b && b < _n);
        int x = leader(a), y = leader(b);
        if (x == y)
            return x;
        if (-parent_or_size[x] < -parent_or_size[y])
        {
            auto tmp = x;
            x = y;
            y = tmp;
        }
        parent_or_size[x] += parent_or_size[y];
        parent_or_size[y] = x;
        return x;
    }

    bool same(long a, long b) @safe nothrow @nogc
    {
        assert(0 <= a && a < _n);
        assert(0 <= b && b < _n);
        return leader(a) == leader(b);
    }

    int leader(long a) @safe nothrow @nogc
    {
        assert(0 <= a && a < _n);
        if (parent_or_size[a] < 0)
            return cast(int) a;
        return parent_or_size[a] = leader(parent_or_size[a]);
    }

    int size(long a) @safe nothrow @nogc
    {
        assert(0 <= a && a < _n);
        return -parent_or_size[leader(a)];
    }

    int[][] groups() @safe nothrow
    {
        auto leader_buf = new int[](_n), group_size = new int[](_n);
        foreach (i; 0 .. _n)
        {
            leader_buf[i] = leader(i);
            group_size[leader_buf[i]]++;
        }
        auto result = new int[][](_n);
        foreach (i; 0 .. _n)
            result[i].reserve(group_size[i]);
        foreach (i; 0 .. _n)
            result[leader_buf[i]] ~= i;
        int[][] filtered;
        foreach (r; result)
            if (r.length != 0)
                filtered ~= r;
        return filtered;
    }

private:
    int _n;
    int[] parent_or_size;
}
