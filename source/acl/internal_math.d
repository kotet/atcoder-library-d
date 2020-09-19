module acl.internal_math;

unittest
{
    assert(safeMod(11, 5) == 1);
    assert(safeMod(-11, 5) == 4);

    assert(ctPowMod(12_345_678, 87_654_321, 1_000_000_007) == 904_406_885);

    assert(isPrime!(1_000_000_007));
    assert(!isPrime!(1_000_000_006));

    assert(invGcd(7, 4) == Tuple!(long, long)(1, 3));
    assert(invGcd(630, 300) == Tuple!(long, long)(30, 1));

    assert(primitiveRoot!(7) == 3);
}

// --- internal_math ---

import std.typecons : Tuple;

ulong safeMod(long x, long m) @safe pure nothrow @nogc
{
    x %= m;
    if (x < 0)
        x += m;
    return x;
}

long ctPowMod(long x, long n, int m) @safe pure nothrow @nogc
{
    if (m == 1)
        return 0;
    uint _m = cast(uint) m;
    ulong r = 1;
    ulong y = safeMod(x, m);
    while (n)
    {
        if (n & 1)
            r = (r * y) % _m;
        y = (y * y) % _m;
        n >>= 1;
    }
    return r;
}

bool ctIsPrime(int n) @safe pure nothrow @nogc
{
    if (n <= 1)
        return false;
    if (n == 2 || n == 7 || n == 61)
        return true;
    if (n % 2 == 0)
        return false;
    long d = n - 1;
    while (d % 2 == 0)
        d /= 2;
    foreach (a; [2, 7, 61])
    {
        long t = d;
        long y = ctPowMod(a, t, n);
        while (t != n - 1 && y != 1 && y != n - 1)
        {
            y = y * y % n;
            t <<= 1;
        }
        if (y != n - 1 && t % 2 == 0)
        {
            return false;
        }
    }
    return true;
}

enum bool isPrime(int n) = ctIsPrime(n);

Tuple!(long, long) invGcd(long a, long b) @safe pure nothrow @nogc
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

int ctPrimitiveRoot(int m) @safe pure nothrow @nogc
{
    if (m == 2)
        return 1;
    if (m == 167_772_161)
        return 3;
    if (m == 469_762_049)
        return 3;
    if (m == 754_974_721)
        return 11;
    if (m == 998_244_353)
        return 3;
    int[20] divs;
    divs[0] = 2;
    int cnt = 1;
    int x = (m - 1) / 2;
    while (x % 2 == 0)
        x /= 2;
    for (int i = 3; (cast(long) i) * i <= x; i += 2)
        if (x % i == 0)
        {
            divs[cnt++] = i;
            while (x % i == 0)
                x /= i;
        }
    if (x > 1)
        divs[cnt++] = x;
    for (int g = 2;; g++)
    {
        bool ok = true;
        foreach (i; 0 .. cnt)
            if (ctPowMod(g, (m - 1) / divs[i], m) == 1)
            {
                ok = false;
                break;
            }
        if (ok)
            return g;
    }
}

enum primitiveRoot(int m) = ctPrimitiveRoot(m);
