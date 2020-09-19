module acl.convolution;

import acl.internal_math;
import acl.modint;
import acl.internal_bit;

// --- convolution ---

import std.traits : isInstanceOf, isIntegral;

void butterfly(mint)(ref mint[] a) @safe nothrow @nogc if (isInstanceOf!(StaticModInt, mint))
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

void butterflyInv(mint)(ref mint[] a) @safe nothrow @nogc if (isInstanceOf!(StaticModInt, mint))
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
        foreach (i; 0 .. cnt2 - 2)
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

mint[] convolution(mint)(ref mint[] a, ref mint[] b) @safe nothrow
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

T[] convolution(uint mod = 998_244_353, T)(const ref T[] a, const ref T[] b) @safe nothrow
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

long[] convolutionLL(const ref long[] a, const ref long[] b) @safe nothrow
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
    static immutable ulong i1 = invGcd(M2M3, MOD1)[1];
    static immutable ulong i2 = invGcd(M1M3, MOD2)[1];
    static immutable ulong i3 = invGcd(M1M2, MOD3)[1];

    auto c1 = convolution!(MOD1)(a, b);
    auto c2 = convolution!(MOD2)(a, b);
    auto c3 = convolution!(MOD3)(a, b);

    auto c = new long[](n + m - 1);
    foreach (i; 0 .. n + m - 1)
    {
        ulong x;
        x += (c1[i] + i1) % MOD1 * M2M3;
        x += (c2[i] + i2) % MOD2 * M1M3;
        x += (c3[i] + i3) % MOD3 * M1M2;
        long diff = c1[i] - safeMod(cast(long) x, cast(long) MOD1);
        if (diff < 0)
            diff += MOD1;
        static immutable ulong[5] offset = [0, 0, M1M2M3, 2 * M1M2M3, 3 * M1M2M3];
        x -= offset[diff % 5];
        c[i] = x;
    }
    return c;
}
