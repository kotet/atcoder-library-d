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

// --- math ---

import std.typecons : Tuple;

long powMod(long x, long n, long m)
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

long invMod(long x, long m)
{
    assert(1 <= m);
    auto z = invGcd(x, m);
    assert(z[0] == 1);
    return z[1];
}

Tuple!(long, long) crt(long[] r, long[] m)
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

long floorSum(long n, long m, long a, long b)
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
