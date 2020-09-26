module acl.convolution;

import acl.internal_math;
import acl.modint;
import acl.internal_bit;

unittest
{
    assert(cast(int[])([]) == convolution(cast(int[])([]), cast(int[])([])));
    assert(cast(int[])([]) == convolution(cast(int[])([]), [1, 2]));
    assert(cast(int[])([]) == convolution([1, 2], cast(int[])([])));
    assert(cast(int[])([]) == convolution([1], cast(int[])([])));

    assert(cast(long[])([]) == convolution(cast(long[])([]), cast(long[])([])));
    assert(cast(long[])([]) == convolution(cast(long[])([]), [1L, 2L]));
    assert(cast(modint998244353[])([]) == convolution(cast(modint998244353[])([]),
            cast(modint998244353[])([])));
    assert(cast(modint998244353[])([]) == convolution(cast(modint998244353[])([]),
            [modint998244353(1), modint998244353(2)]));
}

mint[] convNaive(mint)(mint[] a, mint[] b) if (isInstanceOf!(StaticModInt, mint))
{
    int n = cast(int) a.length, m = cast(int) b.length;
    auto c = new mint[](n + m - 1);
    foreach (i; 0 .. n)
        foreach (j; 0 .. m)
            c[i + j] += a[i] * b[j];
    return c;
}

T[] convNaive(int MOD, T)(T[] a, T[] b) if (isIntegral!(T))
{
    int n = cast(int) a.length, m = cast(int) b.length;
    auto c = new T[](n + m - 1);
    foreach (i; 0 .. n)
        foreach (j; 0 .. m)
        {
            c[i + j] += cast(T)((cast(long) a[i] * cast(long) b[j]) % MOD);
            if (c[i + j] >= MOD)
                c[i + j] -= MOD;
        }
    return c;
}

unittest
{
    import std.random : Mt19937, uniform;

    Mt19937 rnd;
    {
        int n = 1234, m = 2345;
        auto a = new modint998244353[](n);
        auto b = new modint998244353[](m);
        foreach (i; 0 .. n)
            a[i] = modint998244353(uniform(0, modint998244353.mod(), rnd));
        foreach (i; 0 .. m)
            b[i] = modint998244353(uniform(0, modint998244353.mod(), rnd));
        assert(convNaive(a, b) == convolution(a, b));
    }
    {
        enum MOD = 998_244_353;
        alias mint = StaticModInt!MOD;
        foreach (n; 1 .. 20)
            foreach (m; 1 .. 20)
            {
                auto a = new mint[](n);
                auto b = new mint[](m);
                foreach (i; 0 .. n)
                    a[i] = mint(uniform(0, MOD, rnd));
                foreach (i; 0 .. m)
                    b[i] = mint(uniform(0, MOD, rnd));
                assert(convNaive(a, b) == convolution(a, b));
            }
    }
    {
        enum MOD = 924_844_033;
        alias mint = StaticModInt!MOD;
        foreach (n; 1 .. 20)
            foreach (m; 1 .. 20)
            {
                auto a = new mint[](n);
                auto b = new mint[](m);
                foreach (i; 0 .. n)
                    a[i] = mint(uniform(0, MOD, rnd));
                foreach (i; 0 .. m)
                    b[i] = mint(uniform(0, MOD, rnd));
                assert(convNaive(a, b) == convolution(a, b));
            }
    }
}

unittest
{

    import std.random : Mt19937, uniform;

    Mt19937 rnd;
    {
        enum MOD = 998_244_353;
        alias mint = StaticModInt!MOD;
        foreach (n; 1 .. 20)
            foreach (m; 1 .. 20)
            {
                auto a = new uint[](n);
                auto b = new uint[](m);
                foreach (i; 0 .. n)
                    a[i] = uniform(0, MOD, rnd);
                foreach (i; 0 .. m)
                    b[i] = uniform(0, MOD, rnd);
                assert(convNaive!MOD(a, b) == convolution(a, b));
                assert(convNaive!MOD(a, b) == convolution!MOD(a, b));
            }
    }
    {
        enum MOD = 924_844_033;
        alias mint = StaticModInt!MOD;
        foreach (n; 1 .. 20)
            foreach (m; 1 .. 20)
            {
                auto a = new uint[](n);
                auto b = new uint[](m);
                foreach (i; 0 .. n)
                    a[i] = uniform(0, MOD, rnd);
                foreach (i; 0 .. m)
                    b[i] = uniform(0, MOD, rnd);
                assert(convNaive!MOD(a, b) == convolution!MOD(a, b));
            }
    }
    {
        enum MOD = 998_244_353;
        alias mint = StaticModInt!MOD;
        foreach (n; 1 .. 20)
            foreach (m; 1 .. 20)
            {
                auto a = new long[](n);
                auto b = new long[](m);
                foreach (i; 0 .. n)
                    a[i] = uniform(0, MOD, rnd);
                foreach (i; 0 .. m)
                    b[i] = uniform(0, MOD, rnd);
                assert(convNaive!MOD(a, b) == convolution(a, b));
                assert(convNaive!MOD(a, b) == convolution!MOD(a, b));
            }
    }
    {
        enum MOD = 924_844_033;
        alias mint = StaticModInt!MOD;
        foreach (n; 1 .. 20)
            foreach (m; 1 .. 20)
            {
                auto a = new long[](n);
                auto b = new long[](m);
                foreach (i; 0 .. n)
                    a[i] = uniform(0, MOD, rnd);
                foreach (i; 0 .. m)
                    b[i] = uniform(0, MOD, rnd);
                assert(convNaive!MOD(a, b) == convolution!MOD(a, b));
            }
    }
    {
        enum MOD = 998_244_353;
        alias mint = StaticModInt!MOD;
        foreach (n; 1 .. 20)
            foreach (m; 1 .. 20)
            {
                auto a = new ulong[](n);
                auto b = new ulong[](m);
                foreach (i; 0 .. n)
                    a[i] = uniform(0, MOD, rnd);
                foreach (i; 0 .. m)
                    b[i] = uniform(0, MOD, rnd);
                assert(convNaive!MOD(a, b) == convolution(a, b));
                assert(convNaive!MOD(a, b) == convolution!MOD(a, b));
            }
    }
    {
        enum MOD = 924_844_033;
        alias mint = StaticModInt!MOD;
        foreach (n; 1 .. 20)
            foreach (m; 1 .. 20)
            {
                auto a = new ulong[](n);
                auto b = new ulong[](m);
                foreach (i; 0 .. n)
                    a[i] = uniform(0, MOD, rnd);
                foreach (i; 0 .. m)
                    b[i] = uniform(0, MOD, rnd);
                assert(convNaive!MOD(a, b) == convolution!MOD(a, b));
            }
    }
}

unittest
{
    long[] convLLNaive(long[] a, long[] b)
    {
        int n = cast(int) a.length, m = cast(int) b.length;
        auto c = new long[](n + m - 1);
        foreach (i; 0 .. n)
            foreach (j; 0 .. m)
                c[i + j] += a[i] * b[j];
        return c;
    }

    import std.random : Mt19937, uniform;

    Mt19937 rnd;
    foreach (n; 1 .. 20)
        foreach (m; 1 .. 20)
        {
            auto a = new long[](n);
            auto b = new long[](m);
            foreach (i; 0 .. n)
                a[i] = uniform(-500_000, 500_000, rnd);
            foreach (i; 0 .. m)
                b[i] = uniform(-500_000, 500_000, rnd);
            assert(convLLNaive(a, b) == convolutionLL(a, b));
        }
}

unittest
{
    static immutable ulong MOD1 = 90 * (2 ^^ 23) + 1;
    static immutable ulong MOD2 = 10 * (2 ^^ 24) + 1;
    static immutable ulong MOD3 = 14 * (2 ^^ 25) + 1;
    static assert(MOD1 == 754_974_721 && MOD2 == 167_772_161 && MOD3 == 469_762_049);
    static immutable ulong M2M3 = MOD2 * MOD3;
    static immutable ulong M1M3 = MOD1 * MOD3;
    static immutable ulong M1M2 = MOD1 * MOD2;
    foreach (i; -1000 .. 1000 + 1)
    {
        long[] a = [0 - M1M2 - M1M3 - M2M3 + i];
        long[] b = [1];
        assert(a == convolutionLL(a, b));
    }
    foreach (i; 0 .. 1000)
    {
        long[] a = [long.min + i];
        long[] b = [1];
        assert(a == convolutionLL(a, b));
    }
    foreach (i; 0 .. 1000)
    {
        long[] a = [long.max - i];
        long[] b = [1];
        assert(a == convolutionLL(a, b));
    }
}

unittest
{
    import std.random : Mt19937, uniform;

    Mt19937 rnd;
    enum MOD = 128 * 5 + 1;
    auto a = new long[](64);
    auto b = new long[](65);
    foreach (i; 0 .. 64)
        a[i] = uniform(0, MOD);
    foreach (i; 0 .. 65)
        b[i] = uniform(0, MOD);
    assert(convNaive!(MOD)(a, b) == convolution!(MOD)(a, b));
}

unittest
{
    import std.random : Mt19937, uniform;

    Mt19937 rnd;
    enum MOD = 2048 * 9 + 1;
    auto a = new long[](1024);
    auto b = new long[](1025);
    foreach (i; 0 .. 1024)
        a[i] = uniform(0, MOD);
    foreach (i; 0 .. 1025)
        b[i] = uniform(0, MOD);
    assert(convNaive!(MOD)(a, b) == convolution!(MOD)(a, b));
}

// --- convolution ---

import std.traits : isInstanceOf, isIntegral;

void butterfly(mint)(mint[] a) @safe nothrow @nogc
        if (isInstanceOf!(StaticModInt, mint))
{
    import core.bitop : bsf;

    static immutable int g = primitiveRoot!(mint.mod());
    int n = cast(int) a.length;
    int h = celiPow2(n);

    static bool first = true;
    static mint[30] sum_e;
    if (first)
    {
        first = false;
        mint[30] es, ies;
        int cnt2 = bsf(mint.mod() - 1);
        mint e = mint(g).pow((mint.mod() - 1) >> cnt2);
        mint ie = e.inv();
        foreach_reverse (i; 2 .. cnt2 + 1)
        {
            es[i - 2] = e;
            ies[i - 2] = ie;
            e *= e;
            ie *= ie;
        }
        mint now = 1;
        foreach (i; 0 .. cnt2 - 2 + 1)
        {
            sum_e[i] = es[i] * now;
            now *= ies[i];
        }
    }
    foreach (ph; 1 .. h + 1)
    {
        int w = 1 << (ph - 1), p = 1 << (h - ph);
        mint now = 1;
        foreach (s; 0 .. w)
        {
            int offset = s << (h - ph + 1);
            foreach (i; 0 .. p)
            {
                auto l = a[i + offset];
                auto r = a[i + offset + p] * now;
                a[i + offset] = l + r;
                a[i + offset + p] = l - r;
            }
            now *= sum_e[bsf(~(cast(uint) s))];
        }
    }
}

void butterflyInv(mint)(mint[] a) @safe nothrow @nogc
        if (isInstanceOf!(StaticModInt, mint))
{
    import core.bitop : bsf;

    static immutable int g = primitiveRoot!(mint.mod());
    int n = cast(int) a.length;
    int h = celiPow2(n);

    static bool first = true;
    static mint[30] sum_ie;
    if (first)
    {
        first = false;
        mint[30] es, ies;
        int cnt2 = bsf(mint.mod() - 1);
        mint e = mint(g).pow((mint.mod() - 1) >> cnt2);
        mint ie = e.inv();
        foreach_reverse (i; 2 .. cnt2 + 1)
        {
            es[i - 2] = e;
            ies[i - 2] = ie;
            e *= e;
            ie *= ie;
        }
        mint now = 1;
        foreach (i; 0 .. cnt2 - 2 + 1)
        {
            sum_ie[i] = ies[i] * now;
            now *= es[i];
        }
    }

    foreach_reverse (ph; 1 .. h + 1)
    {
        int w = 1 << (ph - 1), p = 1 << (h - ph);
        mint inow = 1;
        foreach (s; 0 .. w)
        {
            int offset = s << (h - ph + 1);
            foreach (i; 0 .. p)
            {
                auto l = a[i + offset];
                auto r = a[i + offset + p];
                a[i + offset] = l + r;
                a[i + offset + p] = mint(cast(ulong)(mint.mod() + l.val() - r.val()) * inow.val());
            }
            inow *= sum_ie[bsf(~(cast(uint) s))];
        }
    }
}

mint[] convolution(mint)(mint[] a, mint[] b) @safe nothrow 
        if (isInstanceOf!(StaticModInt, mint))
{
    import std.algorithm : min, swap;

    int n = cast(int) a.length, m = cast(int) b.length;
    if (!n || !m)
        return [];
    if (min(n, m) <= 60)
    {
        if (n < m)
        {
            swap(n, m);
            swap(a, b);
        }
        auto ans = new mint[](n + m - 1);
        foreach (i; 0 .. n)
            foreach (j; 0 .. m)
                ans[i + j] += a[i] * b[j];
        return ans;
    }
    int z = 1 << celiPow2(n + m - 1);
    a.length = z;
    butterfly(a);
    b.length = z;
    butterfly(b);
    foreach (i; 0 .. z)
        a[i] *= b[i];
    butterflyInv(a);
    a.length = n + m - 1;
    mint iz = mint(z).inv();
    foreach (i; 0 .. n + m - 1)
        a[i] *= iz;
    return a;
}

T[] convolution(uint mod = 998_244_353, T)(T[] a, T[] b) @safe nothrow 
        if (isIntegral!(T))
{
    int n = cast(int)(a.length), m = cast(int)(b.length);
    if (!n || !m)
        return [];
    alias mint = StaticModInt!(mod);
    auto a2 = new mint[](n), b2 = new mint[](m);
    foreach (i; 0 .. n)
        a2[i] = mint(a[i]);
    foreach (i; 0 .. m)
        b2[i] = mint(b[i]);
    auto c2 = convolution(a2, b2);
    auto c = new T[](n + m - 1);
    foreach (i; 0 .. n + m - 1)
        c[i] = c2[i].val();
    return c;
}

long[] convolutionLL(long[] a, long[] b) @safe nothrow
{
    int n = cast(int)(a.length), m = cast(int)(b.length);
    if (!n || !m)
        return [];
    static immutable ulong MOD1 = 90 * (2 ^^ 23) + 1;
    static immutable ulong MOD2 = 10 * (2 ^^ 24) + 1;
    static immutable ulong MOD3 = 14 * (2 ^^ 25) + 1;
    static assert(MOD1 == 754_974_721 && MOD2 == 167_772_161 && MOD3 == 469_762_049);
    static immutable ulong M2M3 = MOD2 * MOD3;
    static immutable ulong M1M3 = MOD1 * MOD3;
    static immutable ulong M1M2 = MOD1 * MOD2;
    static immutable ulong M1M2M3 = MOD1 * MOD2 * MOD3;
    static immutable ulong i1 = invGcd(MOD2 * MOD3, MOD1)[1];
    static immutable ulong i2 = invGcd(MOD1 * MOD3, MOD2)[1];
    static immutable ulong i3 = invGcd(MOD1 * MOD2, MOD3)[1];

    auto c1 = convolution!(MOD1)(a, b);
    auto c2 = convolution!(MOD2)(a, b);
    auto c3 = convolution!(MOD3)(a, b);

    auto c = new long[](n + m - 1);
    foreach (i; 0 .. n + m - 1)
    {
        ulong x;
        x += (c1[i] * i1) % MOD1 * M2M3;
        x += (c2[i] * i2) % MOD2 * M1M3;
        x += (c3[i] * i3) % MOD3 * M1M2;
        long diff = c1[i] - safeMod(cast(long) x, cast(long) MOD1);
        if (diff < 0)
            diff += MOD1;
        static immutable ulong[5] offset = [0, 0, M1M2M3, 2 * M1M2M3, 3 * M1M2M3];
        x -= offset[diff % 5];
        c[i] = x;
    }
    return c;
}
