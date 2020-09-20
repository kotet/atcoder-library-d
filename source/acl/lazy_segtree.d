module acl.lazy_segtree;

import acl.internal_bit;

unittest
{
    import std.algorithm;
    import std.exception;

    struct starry
    {
        static int op_ss(int a, int b)
        {
            return max(a, b);
        }

        static int op_ts(int a, int b)
        {
            return a + b;
        }

        static int op_tt(int a, int b)
        {
            return a + b;
        }

        static int e_s()
        {
            return -1_000_000_000;
        }

        static int e_t()
        {
            return 0;
        }
    }

    alias starry_seg = LazySegTree!(int, starry.op_ss, starry.e_s, int,
            starry.op_ts, starry.op_tt, starry.e_t);

    {
        auto s = starry_seg(0);
        assert(-1_000_000_000 == s.allProd());
    }
    {
        starry_seg s;
        assert(-1_000_000_000 == s.allProd());
    }
    {
        auto s = starry_seg(10);
        assert(-1_000_000_000 == s.allProd());
    }
    {
        starry_seg seg0;
        seg0 = starry_seg(10);
    }
    {
        assertThrown!Error(starry_seg(-1));
        auto s = starry_seg(10);
        assertThrown!Error(s.get(-1));
        assertThrown!Error(s.get(10));
        assertThrown!Error(s.prod(-1, -1));
        assertThrown!Error(s.prod(3, 2));
        assertThrown!Error(s.prod(0, 11));
        assertThrown!Error(s.prod(-1, 11));
    }
    {
        foreach (n; 0 .. 50 + 1)
        {
            auto seg = starry_seg(n);
            auto p = new int[](n);
            foreach (i; 0 .. n)
            {
                p[i] = (i * i + 100) % 31;
                seg.set(i, p[i]);
            }
            foreach (l; 0 .. n + 1)
                foreach (r; l .. n + 1)
                {
                    int e = -1_000_000_000;
                    foreach (i; l .. r)
                    {
                        e = max(e, p[i]);
                    }
                    assert(e == seg.prod(l, r));
                }
        }
    }
    {
        auto seg = starry_seg(new int[](10));
        assert(0 == seg.allProd());
        seg.apply(0, 3, 5);
        assert(5 == seg.allProd());
        seg.apply(2, -10);
        assert(-5 == seg.prod(2, 3));
        assert(0 == seg.prod(2, 4));
    }
}

unittest
{
    import std.algorithm;
    import std.random;
    import std.typecons;

    struct time_manager
    {
        int[] v;
        this(int n)
        {
            v = new int[](n);
            v[] = -1;
        }

        void action(int l, int r, int time)
        {
            foreach (i; l .. r)
            {
                v[i] = time;
            }
        }

        int prod(int l, int r)
        {
            int res = -1;
            foreach (i; l .. r)
            {
                res = max(res, v[i]);
            }
            return res;
        }
    }

    struct S
    {
        int l, r, time;
    }

    struct T
    {
        int new_time;
    }

    S op_ss(S l, S r)
    {
        if (l.l == -1)
            return r;
        if (r.l == -1)
            return l;
        assert(l.r == r.l);
        return S(l.l, r.r, max(l.time, r.time));
    }

    S op_ts(T l, S r)
    {
        if (l.new_time == -1)
            return r;
        assert(r.time < l.new_time);
        return S(r.l, r.r, l.new_time);
    }

    T op_tt(T l, T r)
    {
        if (l.new_time == -1)
            return r;
        if (r.new_time == -1)
            return l;
        assert(l.new_time > r.new_time);
        return l;
    }

    S e_s()
    {
        return S(-1, -1, -1);
    }

    T e_t()
    {
        return T(-1);
    }

    alias seg = LazySegTree!(S, op_ss, e_s, T, op_ts, op_tt, e_t);

    Tuple!(T, T) randpair(T)(T lower, T upper)
    {
        assert(upper - lower >= 1);
        T a, b;
        do
        {
            a = uniform(lower, upper + 1);
            b = uniform(lower, upper + 1);
        }
        while (a == b);
        if (a > b)
            swap(a, b);
        return Tuple!(T, T)(a, b);
    }

    {
        foreach (n; 1 .. 30 + 1)
            foreach (ph; 0 .. 10)
            {
                auto seg0 = seg(n);
                auto tm = time_manager(n);
                foreach (i; 0 .. n)
                    seg0.set(i, S(i, i + 1, -1));
                int now = 0;
                foreach (q; 0 .. 3000)
                {
                    int ty = uniform(0, 3 + 1);
                    auto pair = randpair!int(0, n);
                    int l = pair[0];
                    int r = pair[1];
                    if (ty == 0)
                    {
                        auto res = seg0.prod(l, r);
                        assert(l == res.l);
                        assert(r == res.r);
                        assert(tm.prod(l, r) == res.time);
                    }
                    else if (ty == 1)
                    {
                        auto res = seg0.get(l);
                        assert(l == res.l);
                        assert(l + 1 == res.r);
                        assert(tm.prod(l, l + 1) == res.time);
                    }
                    else if (ty == 2)
                    {
                        now++;
                        seg0.apply(l, r, T(now));
                        tm.action(l, r, now);
                    }
                    else if (ty == 3)
                    {
                        now++;
                        seg0.apply(l, T(now));
                        tm.action(l, l + 1, now);
                    }
                    else
                        assert(false);
                }
            }
    }
    {
        foreach (n; 1 .. 30 + 1)
            foreach (ph; 0 .. 10)
            {
                auto seg0 = seg(n);
                auto tm = time_manager(n);
                foreach (i; 0 .. n)
                    seg0.set(i, S(i, i + 1, -1));
                int now = 0;
                foreach (q; 0 .. 1000)
                {
                    int ty = uniform(0, 2 + 1);
                    auto pair = randpair!int(0, n);
                    int l = pair[0];
                    int r = pair[1];
                    if (ty == 0)
                    {
                        assert(r == seg0.maxRight(l, (S s) {
                                if (s.l == -1)
                                    return true;
                                assert(s.l == l);
                                assert(s.time == tm.prod(l, s.r));
                                return s.r <= r;
                            }));
                    }
                    else
                    {
                        now++;
                        seg0.apply(l, r, T(now));
                        tm.action(l, r, now);
                    }
                }
            }
    }
    {
        foreach (n; 1 .. 30 + 1)
            foreach (ph; 0 .. 10)
            {
                auto seg0 = seg(n);
                auto tm = time_manager(n);
                foreach (i; 0 .. n)
                    seg0.set(i, S(i, i + 1, -1));
                int now = 0;
                foreach (q; 0 .. 1000)
                {
                    int ty = uniform(0, 2 + 1);
                    auto pair = randpair!int(0, n);
                    int l = pair[0];
                    int r = pair[1];
                    if (ty == 0)
                    {
                        assert(l == seg0.minLeft(r, (S s) {
                                if (s.l == -1)
                                    return true;
                                assert(s.r == r);
                                assert(s.time == tm.prod(s.l, r));
                                return l <= s.l;
                            }));
                    }
                    else
                    {
                        now++;
                        seg0.apply(l, r, T(now));
                        tm.action(l, r, now);
                    }
                }
            }
    }
}

// --- lazy_segtree ---

struct LazySegTree(S, alias op, alias e, F, alias mapping, alias composition, alias id)
{
    import std.functional : unaryFun, binaryFun;
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
    static if (is(typeof(id) : string))
    {
        auto identity()
        {
            return mixin(id);
        }
    }
    else
    {
        alias identity = id;
    }
public:
    this(int n)
    {
        auto v = new S[](n);
        v[] = unit();
        this(v);
    }

    this(const S[] v)
    {
        _n = cast(int) v.length;
        log = celiPow2(_n);
        size = 1 << log;
        assert(1 <= size);
        d = new S[](2 * size);
        d[] = unit();
        lz = new F[](size);
        lz[] = identity();
        foreach (i; 0 .. _n)
            d[size + i] = v[i];
        foreach_reverse (i; 1 .. size)
            update(i);
    }

    void set(int p, S x)
    {
        assert(0 <= p && p < _n);
        p += size;
        foreach_reverse (i; 1 .. log + 1)
            push(p >> i);
        d[p] = x;
        foreach (i; 1 .. log + 1)
            update(p >> i);
    }

    S get(int p)
    {
        assert(0 <= p && p < _n);
        p += size;
        foreach_reverse (i; 1 .. log + 1)
            push(p >> i);
        return d[p];
    }

    S prod(int l, int r)
    {
        assert(0 <= l && l <= r && r <= _n);
        if (l == r)
            return unit();
        l += size;
        r += size;
        foreach_reverse (i; 1 .. log + 1)
        {
            if (((l >> i) << i) != l)
                push(l >> i);
            if (((r >> i) << i) != r)
                push(r >> i);
        }

        S sml = unit(), smr = unit();
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

    void apply(int p, F f)
    {
        assert(0 <= p && p < _n);
        p += size;
        foreach_reverse (i; 1 .. log + 1)
            push(p >> i);
        d[p] = binaryFun!(mapping)(f, d[p]);
        foreach (i; 1 .. log + 1)
            update(p >> i);
    }

    void apply(int l, int r, F f)
    {
        assert(0 <= l && l <= r && r <= _n);
        if (l == r)
            return;
        l += size;
        r += size;
        foreach_reverse (i; 1 .. log + 1)
        {
            if (((l >> i) << i) != l)
                push(l >> i);
            if (((r >> i) << i) != r)
                push((r - 1) >> i);
        }
        {
            int l2 = l, r2 = r;
            while (l < r)
            {
                if (l & 1)
                    all_apply(l++, f);
                if (r & 1)
                    all_apply(--r, f);
                l >>= 1;
                r >>= 1;
            }
            l = l2;
            r = r2;
        }
        foreach (i; 1 .. log + 1)
        {
            if (((l >> i) << i) != l)
                update(l >> i);
            if (((r >> i) << i) != r)
                update((r - 1) >> i);
        }
    }

    int maxRight(alias g)(int l)
    {
        return maxRight(l, unaryFun!(g));
    }

    int maxRight(G)(int l, G g) if (isCallable!G && Parameters!(G).length == 1)
    {
        assert(0 <= l && l <= _n);
        assert(g(unit()));
        if (l == _n)
            return _n;
        l += size;
        foreach_reverse (i; 1 .. log + 1)
            push(l >> i);
        S sm = unit();
        do
        {
            while (l % 2 == 0)
                l >>= 1;
            if (!g(binaryFun!(op)(sm, d[l])))
            {
                while (l < size)
                {
                    push(l);
                    l = 2 * l;
                    if (g(binaryFun!(op)(sm, d[l])))
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

    int minLeft(alias g)(int r)
    {
        return minLeft(r, unaryFun!(g));
    }

    int minLeft(G)(int r, G g) if (isCallable!G && Parameters!(G).length == 1)
    {
        assert(0 <= r && r <= _n);
        assert(g(unit()));
        if (r == 0)
            return 0;
        r += size;
        foreach_reverse (i; 1 .. log + 1)
            push((r - 1) >> i);
        S sm = unit();
        do
        {
            r--;
            while (r > 1 && (r % 2))
                r >>= 1;
            if (!g(binaryFun!(op)(d[r], sm)))
            {
                while (r < size)
                {
                    push(r);
                    r = (2 * r + 1);
                    if (g(binaryFun!(op)(d[r], sm)))
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
    F[] lz = [identity()];

    void update(int k)
    {
        d[k] = binaryFun!(op)(d[2 * k], d[2 * k + 1]);
    }

    void all_apply(int k, F f)
    {
        d[k] = binaryFun!(mapping)(f, d[k]);
        if (k < size)
            lz[k] = binaryFun!(composition)(f, lz[k]);
    }

    void push(int k)
    {
        all_apply(2 * k, lz[k]);
        all_apply(2 * k + 1, lz[k]);
        lz[k] = identity();
    }
}
