module acl.segtree;

import acl.internal_bit;

// --- segtree ---

struct segtree(S, alias op, alias e)
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
        this(new S[](n));
    }

    this(S[] v)
    {

        _n = cast(int) v.length;
        log = ceil_pow2(_n);
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

    S all_prod()
    {
        return d[1];
    }

    int max_right(alias f)(int l)
    {
        return max_right(l, unaryFun!(f));
    }

    int max_right(F)(int l, F f) if (isCallable!F && Parameters!(F).length == 1)
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

    int min_left(alias f)(int r)
    {
        return min_left(r, unaryFun!(f));
    }

    int min_left(F)(int r, F f) if (isCallable!F && Parameters!(F).length == 1)
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
    int _n, size, log;
    S[] d;
    void update(int k)
    {
        d[k] = binaryFun!(op)(d[2 * k], d[2 * k + 1]);
    }
}
