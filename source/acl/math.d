module acl.math;
import acl.internal_math;

unittest
{
    assert(powMod(12_345_678, 87_654_321, 1_000_000_007) == 904_406_885);

    assert(invMod(7, 1_000_000_007) == 142_857_144);

    immutable crt_result = crt([80_712, 320_302, 140_367], [
            221_549, 699_312, 496_729
            ]);
    assert(crt_result == Tuple!(long, long)(38_774_484_298_448_350, 76_959_154_983_203_952));

    assert(floorSum(31_415, 92_653, 58_979, 32_384) == 314_095_480);
}

unittest
{
    ulong naive(long x, long n, int mod)
    {
        long y = safeMod(x, mod);
        ulong z = 1 % mod;
        foreach (i; 0 .. n)
            z = (z * y) % mod;
        return z;
    }

    foreach (a; -100 .. 100 + 1)
        foreach (b; 0 .. 100 + 1)
            foreach (c; 1 .. 100 + 1)
                assert(naive(a, b, c) == powMod(a, b, c));
}

unittest
{
    assert(invMod(-1, long.max) == invMod(long.min, long.max));
    assert(1 == invMod(long.max, long.max - 1));
    assert(long.max - 1 == invMod(long.max - 1, long.max));
    assert(2 == invMod(long.max / 2 + 1, long.max));
}

unittest
{
    import std.numeric : gcd;

    foreach (a; -100 .. 100 + 1)
        foreach (b; 1 .. 1000 + 1)
        {
            if (gcd(safeMod(a, b), b) != 1)
                continue;
            long c = invMod(a, b);
            assert(0 <= c);
            assert(c < b);
            assert(1 % b == ((a * c) % b + b) % b);
        }
}

unittest
{
    assert(0 == invMod(0, 1));
    foreach (i; 0 .. 10)
    {
        assert(0 == invMod(i, 1));
        assert(0 == invMod(-i, 1));
        assert(0 == invMod(long.min + i, 1));
        assert(0 == invMod(long.max - i, 1));
    }
}

unittest
{
    long floorSum_naive(long n, long m, long a, long b)
    {
        long sum = 0;
        foreach (i; 0 .. n)
            sum += (a * i + b) / m;
        return sum;
    }

    foreach (n; 0 .. 20)
        foreach (m; 1 .. 20)
            foreach (a; 0 .. 20)
                foreach (b; 0 .. 20)
                {
                    assert(floorSum_naive(n, m, a, b) == floorSum(n, m, a, b));
                }
}

unittest
{
    auto res = crt([1, 2, 1], [2, 3, 2]);
    assert(5 == res[0]);
    assert(6 == res[1]);
}

unittest
{
    import std.numeric : gcd;

    foreach (a; 1 .. 20 + 1)
        foreach (b; 1 .. 20 + 1)
            foreach (c; -10 .. 10 + 1)
                foreach (d; -10 .. 10 + 1)
                {
                    auto res = crt([c, d], [a, b]);
                    if (res[1] == 0)
                    {
                        for (int x = 0; x < a * b / gcd(a, b); x++)
                            assert(x % a != c || x % b != d);
                        continue;
                    }
                    assert(a * b / gcd(a, b) == res[1]);
                    assert(safeMod(c, a) == res[0] % a);
                    assert(safeMod(d, b) == res[0] % b);
                }
}

unittest
{
    import std.numeric : gcd;

    foreach (a; 1 .. 5 + 1)
        foreach (b; 1 .. 5 + 1)
            foreach (c; 1 .. 5 + 1)
                foreach (d; -5 .. 5 + 1)
                    foreach (e; -5 .. 5 + 1)
                        foreach (f; -5 .. 5 + 1)
                        {
                            auto res = crt([d, e, f], [a, b, c]);
                            long lcm = a * b / gcd(a, b);
                            lcm = lcm * c / gcd(lcm, c);
                            if (res[1] == 0)
                            {
                                foreach (x; 0 .. lcm)
                                    assert(x % a != d || x % b != e || x % c != f);
                                continue;
                            }
                            assert(lcm == res[1]);
                            assert(safeMod(d, a) == res[0] % a);
                            assert(safeMod(e, b) == res[0] % b);
                            assert(safeMod(f, c) == res[0] % c);
                        }
}

unittest
{
    long r0 = 0;
    long r1 = 1_000_000_000_000L - 2;
    long m0 = 900577;
    long m1 = 1_000_000_000_000L;
    auto res = crt([r0, r1], [m0, m1]);
    assert(m0 * m1 == res[1]);
    assert(r0 == res[0] % m0);
    assert(r1 == res[0] % m1);
}

unittest
{
    import std.algorithm;
    import std.numeric;

    immutable INF = long.max;
    long[] pred;
    foreach (i; 1 .. 10 + 1)
    {
        pred ~= i;
        pred ~= INF - (i - 1);
    }
    pred ~= 998_244_353;
    pred ~= 1_000_000_007;
    pred ~= 1_000_000_009;

    alias T = Tuple!(long, long);
    foreach (ab; [
            T(INF, INF), T(1, INF), T(INF, 1), T(7, INF), T(INF / 337, 337),
            T(2, (INF - 1) / 2)
        ])
    {
        long a = ab[0];
        long b = ab[1];
        foreach (ph; 0 .. 2)
        {
            foreach (ans; pred)
            {
                auto res = crt([ans % a, ans % b], [a, b]);
                long lcm = a / gcd(a, b) * b;
                assert(lcm == res[1]);
                assert(ans % lcm == res[0]);
            }
            swap(a, b);
        }
    }

    long[] factor_inf = [49, 73, 127, 337, 92_737, 649_657];
    do
    {
        foreach (ans; pred)
        {
            long[] r, m;
            foreach (f; factor_inf)
            {
                r ~= ans % f;
                m ~= f;
            }
            auto res = crt(r, m);
            assert(ans % INF == res[0]);
            assert(INF == res[1]);
        }
    }
    while (nextPermutation(factor_inf));

    long[] factor_infn1 = [2, 3, 715_827_883, 2_147_483_647];
    do
    {
        foreach (ans; pred)
        {
            long[] r, m;
            foreach (f; factor_infn1)
            {
                r ~= ans % f;
                m ~= f;
            }
            auto res = crt(r, m);
            assert(ans % (INF - 1) == res[0]);
            assert(INF - 1 == res[1]);
        }
    }
    while (nextPermutation(factor_infn1));
}

// --- math ---

import std.typecons : Tuple;

long powMod(long x, long n, long m) @safe pure nothrow @nogc
{
    assert(0 <= n && 1 <= m);
    if (m == 1)
        return 0;
    ulong r = 1, y = safeMod(x, m);
    while (n)
    {
        if (n & 1)
            r = (r * y) % m;
        y = (y * y) % m;
        n >>= 1;
    }
    return r;
}

long invMod(long x, long m) @safe pure nothrow @nogc
{
    assert(1 <= m);
    auto z = invGcd(x, m);
    assert(z[0] == 1);
    return z[1];
}

Tuple!(long, long) crt(long[] r, long[] m) @safe pure nothrow @nogc
{
    assert(r.length == m.length);
    long r0 = 0, m0 = 1;
    foreach (i; 0 .. r.length)
    {
        assert(1 <= m[i]);
        long r1 = safeMod(r[i], m[i]);
        long m1 = m[i];
        if (m0 < m1)
        {
            auto tmp = r0;
            r0 = r1;
            r1 = tmp;
            tmp = m0;
            m0 = m1;
            m1 = tmp;
        }
        if (m0 % m1 == 0)
        {
            if (r0 % m1 != r1)
                return Tuple!(long, long)(0, 0);
            continue;
        }
        long g, im;
        {
            auto tmp = invGcd(m0, m1);
            g = tmp[0];
            im = tmp[1];
        }
        long u1 = m1 / g;
        if ((r1 - r0) % g)
            return Tuple!(long, long)(0, 0);
        long x = (r1 - r0) / g % u1 * im % u1;
        r0 += x * m0;
        m0 *= u1;
        if (r0 < 0)
            r0 += m0;
    }
    return Tuple!(long, long)(r0, m0);
}

long floorSum(long n, long m, long a, long b) @safe pure nothrow @nogc
{
    long ans;
    if (m <= a)
    {
        ans += (n - 1) * n * (a / m) / 2;
        a %= m;
    }
    if (m <= b)
    {
        ans += n * (b / m);
        b %= m;
    }
    long y_max = (a * n + b) / m, x_max = (y_max * m - b);
    if (y_max == 0)
        return ans;
    ans += (n - (x_max + a - 1) / a) * y_max;
    ans += floorSum(y_max, a, m, (a - x_max % a) % a);
    return ans;
}
