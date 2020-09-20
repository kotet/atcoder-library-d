module acl.fenwicktree;

unittest
{
    auto ft = FenwickTree!long(100);
    ft.add(0, 1);
    ft.add(4, 10);
    ft.add(9, 100);
    assert(ft.sum(2, 8) == 10);
}

unittest
{
    import acl.modint;

    FenwickTree!(long) fw_ll;
    assert(0 == fw_ll.sum(0, 0));

    FenwickTree!(modint998244353) fw_modint;
    assert(0 == fw_modint.sum(0, 0).val());
}

unittest
{
    FenwickTree!long fw;
    fw = FenwickTree!long(10);
}

unittest
{
    import acl.modint;

    auto fw_ll = FenwickTree!long(0);
    assert(0 == fw_ll.sum(0, 0));

    auto fw_modint = FenwickTree!(modint998244353)(0);
    assert(0 == fw_modint.sum(0, 0).val());
}

unittest
{
    auto fw = FenwickTree!ulong(10);
    foreach (i; 0 .. 10)
        fw.add(i, (1UL << 63) + i);
    foreach (i; 0 .. 10 + 1)
        foreach (j; i .. 10 + 1)
        {
            ulong sum;
            foreach (k; i .. j)
                sum += k;
            assert((((j - i) % 2) ? (1UL << 63) + sum : sum) == fw.sum(i, j));
        }
}

unittest
{
    foreach (n; 0 .. 50 + 1)
    {
        auto fw = FenwickTree!long(n);
        foreach (i; 0 .. n)
            fw.add(i, i * i);
        foreach (l; 0 .. n + 1)
            foreach (r; l .. n + 1)
            {
                long sum = 0;
                foreach (i; l .. r)
                    sum += i * i;
                assert(sum == fw.sum(l, r));
            }
    }
}

unittest
{
    import acl.modint;

    foreach (n; 0 .. 50 + 1)
    {
        auto fw = FenwickTree!(StaticModInt!11)(n);
        foreach (i; 0 .. n)
            fw.add(i, StaticModInt!11(i * i));
        foreach (l; 0 .. n + 1)
            foreach (r; l .. n + 1)
            {
                StaticModInt!11 sum = 0;
                foreach (i; l .. r)
                    sum += i * i;
                assert(sum == fw.sum(l, r));
            }
    }
}

unittest
{
    import acl.modint;

    modint.setMod(11);

    foreach (n; 0 .. 50 + 1)
    {
        auto fw = FenwickTree!(modint)(n);
        foreach (i; 0 .. n)
            fw.add(i, modint(i * i));
        foreach (l; 0 .. n + 1)
            foreach (r; l .. n + 1)
            {
                modint sum = 0;
                foreach (i; l .. r)
                    sum += i * i;
                assert(sum == fw.sum(l, r));
            }
    }
}

unittest
{
    import std.exception;

    assertThrown!Error(FenwickTree!int(-1));
    auto s = FenwickTree!(int)(10);

    assertThrown!Error(s.add(-1, 0));
    assertThrown!Error(s.add(10, 0));

    assertThrown!Error(s.sum(-1, 3));
    assertThrown!Error(s.sum(3, 11));
    assertThrown!Error(s.sum(5, 3));
}

unittest
{
    auto fw = FenwickTree!(int)(10);
    fw.add(3, int.max);
    fw.add(5, int.min);
    assert(-1 == fw.sum(0, 10));
    assert(-1 == fw.sum(3, 6));
    assert(int.max == fw.sum(3, 4));
    assert(int.min == fw.sum(4, 10));
}

unittest
{
    auto fw = FenwickTree!(long)(10);
    fw.add(3, long.max);
    fw.add(5, long.min);
    assert(-1 == fw.sum(0, 10));
    assert(-1 == fw.sum(3, 6));
    assert(long.max == fw.sum(3, 4));
    assert(long.min == fw.sum(4, 10));
}

unittest
{
    auto fw = FenwickTree!(int)(20);
    long[20] a;
    foreach (i; 0 .. 10)
    {
        a[i] += int.max;
        fw.add(i, int.max);
    }
    a[5] += 11_111;
    fw.add(5, 11_111);
    foreach (l; 0 .. 20 + 1)
        foreach (r; l .. 20 + 1)
        {
            long sum;
            foreach (i; l .. r)
                sum += a[i];
            long dif = sum - fw.sum(l, r);
            assert(0 == dif % (1L << 32));
        }
}

// --- fenwicktree ---

struct FenwickTree(T)
{
    import std.traits : isSigned, Unsigned;

    static if (isSigned!T)
    {
        alias U = Unsigned!T;
    }
    else
    {
        alias U = T;
    }
public:
    this(int n) @safe nothrow
    {
        _n = n;
        data = new U[](n);
    }

    void add(int p, T x) @safe nothrow @nogc
    {
        assert(0 <= p && p < _n);
        p++;
        while (p <= _n)
        {
            data[p - 1] += cast(U) x;
            p += p & -p;
        }
    }

    T sum(int l, int r) @safe nothrow @nogc
    {
        assert(0 <= l && l <= r && r <= _n);
        return sum(r) - sum(l);
    }

private:
    int _n;
    U[] data;

    U sum(int r) @safe nothrow @nogc
    {
        U s = 0;
        while (r > 0)
        {
            s += data[r - 1];
            r -= r & -r;
        }
        return s;
    }
}
