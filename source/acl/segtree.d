module acl.segtree;

import acl.internal_bit;

struct segtree_naive(S, alias op, alias e)
{
    int n;
    string[] d;
    this(int _n)
    {
        n = _n;
        d = new string[](n);
        d[] = e();
    }

    void set(int p, S x)
    {
        d[p] = x;
    }

    S get(int p)
    {
        return d[p];
    }

    S prod(int l, int r)
    {
        S sum = e();
        foreach (i; l .. r)
        {
            sum = op(sum, d[i]);
        }
        return sum;
    }

    S all_prod()
    {
        return prod(0, n);
    }

    int max_right(alias f)(int l)
    {
        S sum = e();
        assert(f(sum));
        foreach (i; l .. n)
        {
            sum = op(sum, d[i]);
            if (!f(sum))
                return i;
        }
        return n;
    }

    int min_left(alias f)(int r)
    {
        S sum = e();
        assert(f(sum));
        foreach_reverse (i; 0 .. r)
        {
            sum = op(d[i], sum);
            if (!f(sum))
                return i + 1;
        }
        return 0;
    }
}

string op(string a, string b)
{
    assert(a == "$" || b == "$" || a <= b);
    if (a == "$")
        return b;
    if (b == "$")
        return a;
    return a ~ b;
}

string e()
{
    return "$";
}

alias seg = Segtree!(string, op, e);
alias seg_naive = segtree_naive!(string, op, e);

string y;
bool leq_y(string x)
{
    return x.length <= y.length;
}

unittest
{
    {
        auto s = seg(0);
        assert("$" == s.allProd());
    }
    {
        seg s;
        assert("$" == s.allProd());
    }
}

unittest
{
    import std.exception;

    assertThrown!Error(seg(-1));
    auto s = seg(10);
    assertThrown!Error(s.get(-1));
    assertThrown!Error(s.get(10));

    assertThrown!Error(s.prod(-1, -1));
    assertThrown!Error(s.prod(3, 2));
    assertThrown!Error(s.prod(0, 11));
    assertThrown!Error(s.prod(-1, 11));

    assertThrown!Error(s.maxRight(11, (string s) { return true; }));
    assertThrown!Error(s.minLeft(-1, (string s) { return true; }));
    assertThrown!Error(s.maxRight(0, (string s) { return false; }));
}

unittest
{
    auto s = seg(1);
    assert("$" == s.allProd());
    assert("$" == s.get(0));
    assert("$" == s.prod(0, 1));
    s.set(0, "dummy");
    assert("dummy" == s.get(0));
    assert("$" == s.prod(0, 0));
    assert("dummy" == s.prod(0, 1));
    assert("$" == s.prod(1, 1));
}

unittest
{

    foreach (n; 0 .. 30)
    {
        auto seg0 = seg_naive(n);
        auto seg1 = seg(n);
        foreach (i; 0 .. n)
        {
            string s = "";
            s ~= cast(char)('a' + i);
            seg0.set(i, s);
            seg1.set(i, s);
        }

        foreach (l; 0 .. n + 1)
            foreach (r; l .. n + 1)
            {
                assert(seg0.prod(l, r) == seg1.prod(l, r));
            }

        foreach (l; 0 .. n + 1)
            foreach (r; l .. n + 1)
            {
                y = seg1.prod(l, r);
                assert(seg0.max_right!leq_y(l) == seg1.maxRight!(leq_y)(l));
                assert(seg0.max_right!leq_y(l) == seg1.maxRight(l, (string x) {
                        return x.length <= y.length;
                    }));
            }

        foreach (l; 0 .. n + 1)
            foreach (r; l .. n + 1)
            {
                y = seg1.prod(l, r);
                assert(seg0.min_left!(leq_y)(r) == seg1.minLeft!(leq_y)(r));
                assert(seg0.min_left!(leq_y)(r) == seg1.minLeft(r, (string x) {
                        return x.length <= y.length;
                    }));
            }
    }
}

unittest
{
    seg seg0;
    seg0 = seg(10);
}

// --- segtree ---

struct Segtree(S, alias op, alias e)
{
    import std.functional : binaryFun, unaryFun;
    import std.traits : isCallable, Parameters;

    static if (is(typeof(e) : string))
    {
        auto unit()
        {
            return mixin(e);
        }
    }
    else
    {
        alias unit = e;
    }

    this(int n)
    {
        auto buf = new S[](n);
        buf[] = unit();
        this(buf);
    }

    this(S[] v)
    {
        _n = cast(int) v.length;
        log = celiPow2(_n);
        size = 1 << log;
        d = new S[](2 * size);
        d[] = unit();
        foreach (i; 0 .. _n)
            d[size + i] = v[i];
        foreach_reverse (i; 1 .. size)
            update(i);
    }

    void set(int p, S x)
    {
        assert(0 <= p && p < _n);
        p += size;
        d[p] = x;
        foreach (i; 1 .. log + 1)
            update(p >> i);
    }

    S get(int p)
    {
        assert(0 <= p && p < _n);
        return d[p + size];
    }

    S prod(int l, int r)
    {
        assert(0 <= l && l <= r && r <= _n);
        S sml = unit(), smr = unit();
        l += size;
        r += size;
        while (l < r)
        {
            if (l & 1)
                sml = binaryFun!(op)(sml, d[l++]);
            if (r & 1)
                smr = binaryFun!(op)(d[--r], smr);
            l >>= 1;
            r >>= 1;
        }
        return binaryFun!(op)(sml, smr);
    }

    S allProd()
    {
        return d[1];
    }

    int maxRight(alias f)(int l)
    {
        return maxRight(l, &unaryFun!(f));
    }

    int maxRight(F)(int l, F f) if (isCallable!F && Parameters!(F).length == 1)
    {
        assert(0 <= l && l <= _n);
        assert(f(unit()));
        if (l == _n)
            return _n;
        l += size;
        S sm = unit();
        do
        {
            while (l % 2 == 0)
                l >>= 1;
            if (!f(binaryFun!(op)(sm, d[l])))
            {
                while (l < size)
                {
                    l = 2 * l;
                    if (f(binaryFun!(op)(sm, d[l])))
                    {
                        sm = binaryFun!(op)(sm, d[l]);
                        l++;
                    }
                }
                return l - size;
            }
            sm = binaryFun!(op)(sm, d[l]);
            l++;
        }
        while ((l & -l) != l);
        return _n;
    }

    int minLeft(alias f)(int r)
    {
        return minLeft(r, &unaryFun!(f));
    }

    int minLeft(F)(int r, F f) if (isCallable!F && Parameters!(F).length == 1)
    {
        assert(0 <= r && r <= _n);
        assert(f(unit()));
        if (r == 0)
            return 0;
        r += size;
        S sm = unit();
        do
        {
            r--;
            while (r > 1 && (r % 2))
                r >>= 1;
            if (!f(binaryFun!(op)(d[r], sm)))
            {
                while (r < size)
                {
                    r = 2 * r + 1;
                    if (f(binaryFun!(op)(d[r], sm)))
                    {
                        sm = binaryFun!(op)(d[r], sm);
                        r--;
                    }
                }
                return r + 1 - size;
            }
            sm = binaryFun!(op)(d[r], sm);
        }
        while ((r & -r) != r);
        return 0;
    }

private:
    int _n = 0, size = 1, log = 0;
    S[] d = [unit(), unit()];
    void update(int k)
    {
        d[k] = binaryFun!(op)(d[2 * k], d[2 * k + 1]);
    }
}
