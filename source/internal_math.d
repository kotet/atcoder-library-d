module acl.internal_math;

// --- internal_math ---

import std.typecons : Tuple;

ulong safeMod(long x, long m)
{
    x %= m;
    if (x < 0)
        x += m;
    return x;
}

Tuple!(long, long) invGcd(long a, long b)
{
    a = safeMod(a, b);
    if (a == 0)
        return Tuple!(long, long)(b, 0);
    long s = b, t = a, m0 = 0, m1 = 1;
    while (t)
    {
        long u = s / t;
        s -= t * u;
        m0 -= m1 * u;
        long tmp = s;
        s = t;
        t = tmp;
        tmp = m0;
        m0 = m1;
        m1 = tmp;
    }
    if (m0 < 0)
        m0 += b / s;
    return Tuple!(long, long)(s, m0);
}
