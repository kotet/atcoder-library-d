module acl.modint;

import acl.internal_math;

unittest
{
    alias mint = StaticModInt!(11);

    mint a = 10;
    mint b = mint(3);

    assert(a == 21);
    assert(a == -1);
    assert(-1 == a);

    assert(++a == 0);
    assert(--a == 10);
    a++;
    assert(a == 0);
    a--;
    assert(a == 10);

    assert(-b == 8);

    assert(a + b == 2);
    assert(1 + a == 0);

    assert(a - b == 7);
    assert(b - a == 4);

    assert(a * b == 8);

    assert(b.inv() == 4);

    assert(a / b == 7);

    a += b;
    assert(a == 2 && b == 3);
    a -= b;
    assert(a == 10 && b == 3);
    a *= b;
    assert(a == 8 && b == 3);
    a /= b;
    assert(a == 10 && b == 3);

    assert(mint(2).pow(4) == 5);
    assert(a.val() == 10);

    assert(mint.mod() == 11 && a.mod() == 11);

    assert(mint.raw(3) == 3);
}

unittest
{
    alias mint = modint;

    mint.setMod(11);

    mint a = 10;
    mint b = mint(3);

    assert(a == 21);
    assert(a == -1);
    assert(-1 == a);

    assert(++a == 0);
    assert(--a == 10);
    a++;
    assert(a == 0);
    a--;
    assert(a == 10);

    assert(-b == 8);

    assert(a + b == 2);
    assert(1 + a == 0);

    assert(a - b == 7);
    assert(b - a == 4);

    assert(a * b == 8);

    assert(b.inv() == 4);

    assert(a / b == 7);

    a += b;
    assert(a == 2 && b == 3);
    a -= b;
    assert(a == 10 && b == 3);
    a *= b;
    assert(a == 8 && b == 3);
    a /= b;
    assert(a == 10 && b == 3);

    assert(mint(2).pow(4) == 5);
    assert(a.val() == 10);

    assert(mint.mod() == 11 && a.mod() == 11);

    assert(mint.raw(3) == 3);
}

static assert(modint998244353.mod() == 998_244_353);
static assert(modint1000000007.mod() == 1_000_000_007);

unittest
{
    alias mint = modint;
    immutable mod_upper = int.max;
    for (uint mod = mod_upper; mod >= mod_upper - 20; mod--)
    {
        mint.setMod(mod);
        long[] v;
        foreach (i; 0 .. 10)
        {
            v ~= i;
            v ~= mod - i;
            v ~= mod / 2 + i;
            v ~= mod / 2 - i;
        }
        foreach (a; v)
        {
            assert((((a * a) % mod) * a) % mod == (mint(a).pow(3)).val());
            foreach (b; v)
            {
                assert((a + b) % mod == (mint(a) + mint(b)).val());
                assert((a - b + mod) % mod == (mint(a) - mint(b)).val());
                assert((a * b) % mod == (mint(a) * mint(b)).val());
            }
        }
    }
}

unittest
{
    modint.setMod(998_244_353);
    assert(modint.mod() - 1 != modint(cast(ulong)(-1)).val());
    assert(0 != (cast(ulong)(-1) + modint(1)).val());
    alias mint = StaticModInt!998_244_353;
    assert(mint.mod() - 1 != mint(cast(ulong)(-1)).val());
    assert(0 != (cast(ulong)(-1) + mint(1)).val());
}

unittest
{
    modint.setMod(1);
    foreach (i; 0 .. 100)
        foreach (j; 0 .. 100)
            assert((modint(i) * modint(j)).val() == 0);
    assert((modint(1234) + modint(5678)).val() == 0);
    assert((modint(1234) - modint(5678)).val() == 0);
    assert((modint(1234) * modint(5678)).val() == 0);
    assert(modint(1234).pow(5678) == 0);
    assert(modint(true).val() == 0);

    alias mint = StaticModInt!1;
    foreach (i; 0 .. 100)
        foreach (j; 0 .. 100)
            assert((mint(i) * mint(j)).val() == 0);
    assert((mint(1234) + mint(5678)).val() == 0);
    assert((mint(1234) - mint(5678)).val() == 0);
    assert((mint(1234) * mint(5678)).val() == 0);
    assert(mint(1234).pow(5678) == 0);
    assert(mint(true).val() == 0);
}

unittest
{
    import std.numeric : gcd;

    foreach (i; 1 .. 10)
    {
        int x = StaticModInt!(11)(i).inv().val();
        assert(1 == (x * i) % 11);
    }
    foreach (i; 1 .. 11)
    {
        if (gcd(i, 12) != 1)
            continue;
        int x = StaticModInt!(12)(i).inv().val();
        assert(1 == (x * i) % 12);
    }
    foreach (i; 1 .. 100_000)
    {
        int x = StaticModInt!(1_000_000_007)(i).inv().val();
        assert(1 == (cast(long)(x) * i) % 1_000_000_007);
    }
    foreach (i; 1 .. 100_000)
    {
        if (gcd(i, 1_000_000_008) != 1)
            continue;
        int x = StaticModInt!(1_000_000_008)(i).inv().val();
        assert(1 == (cast(long)(x) * i) % 1_000_000_008);
    }

    modint.setMod(998_244_353);
    foreach (i; 1 .. 100_000)
    {
        int x = modint(i).inv().val();
        assert(0 <= x);
        assert(x <= 998_244_353 - 1);
        assert(1 == (cast(long)(x) * i) % 998_244_353);
    }

    modint.setMod(1_000_000_008);
    foreach (i; 1 .. 100_000)
    {
        if (gcd(i, 1_000_000_008) != 1)
            continue;
        int x = modint(i).inv().val();
        assert(1 == (cast(long)(x) * i) % 1_000_000_008);
    }
}

unittest
{
    alias sint = StaticModInt!(11);
    const sint a = 9;
    assert(9 == a.val());

    alias dint = modint;
    const dint b = 9;
    assert(9 == b.val());
}

unittest
{
    alias sint = StaticModInt!11;
    sint a;
    a = 8;
    assert(9 == (++a).val());
    assert(10 == (++a).val());
    assert(0 == (++a).val());
    assert(1 == (++a).val());
    a = 3;
    assert(2 == (--a).val());
    assert(1 == (--a).val());
    assert(0 == (--a).val());
    assert(10 == (--a).val());
    a = 8;
    assert(8 == (a++).val());
    assert(9 == (a++).val());
    assert(10 == (a++).val());
    assert(0 == (a++).val());
    assert(1 == a.val());
    a = 3;
    assert(3 == (a--).val());
    assert(2 == (a--).val());
    assert(1 == (a--).val());
    assert(0 == (a--).val());
    assert(10 == a.val());
}

unittest
{
    alias dint = modint;
    dint.setMod(11);
    dint a;
    a = 8;
    assert(9 == (++a).val());
    assert(10 == (++a).val());
    assert(0 == (++a).val());
    assert(1 == (++a).val());
    a = 3;
    assert(2 == (--a).val());
    assert(1 == (--a).val());
    assert(0 == (--a).val());
    assert(10 == (--a).val());
    a = 8;
    assert(8 == (a++).val());
    assert(9 == (a++).val());
    assert(10 == (a++).val());
    assert(0 == (a++).val());
    assert(1 == a.val());
    a = 3;
    assert(3 == (a--).val());
    assert(2 == (a--).val());
    assert(1 == (a--).val());
    assert(0 == (a--).val());
    assert(10 == a.val());
}

unittest
{
    import std.exception;

    alias mint = StaticModInt!(11);
    assert(11 == mint.mod());
    assert(4 == +mint(4));
    assert(7 == -mint(4));

    assert(mint(1) != mint(3));
    assert(mint(1) == mint(12));

    assertThrown!Error(mint(3).pow(-1));
}

unittest
{
    import std.exception;

    assert(998_244_353 == DynamicModInt!(12_345).mod());
    alias mint = modint;
    mint.setMod(998_244_353);
    assert(998_244_353 == mint.mod());
    assert(3 == (mint(1) + mint(2)).val());
    assert(3 == (1 + mint(2)).val());
    assert(3 == (mint(1) + 2).val());

    mint.setMod(3);
    assert(3 == mint.mod());
    assert(1 == (mint(2) - mint(1)).val());
    assert(0 == (mint(1) + mint(2)).val());

    mint.setMod(11);
    assert(11 == mint.mod());
    assert(4 == (mint(3) * mint(5)).val());

    assert(4 == +mint(4));
    assert(7 == -mint(4));

    assert(mint(1) != mint(3));
    assert(mint(1) == mint(12));

    assertThrown!Error(mint(3).pow(-1));
}

unittest
{
    modint.setMod(11);
    alias mint = modint;
    assert(1 == mint(true).val());
    assert(3 == mint(cast(char) 3).val());
    assert(3 == mint(cast(dchar) 3).val());
    assert(3 == mint(cast(wchar) 3).val());
    assert(3 == mint(cast(byte) 3).val());
    assert(3 == mint(cast(ubyte) 3).val());
    assert(3 == mint(cast(short) 3).val());
    assert(3 == mint(cast(ushort) 3).val());
    assert(3 == mint(cast(int) 3).val());
    assert(3 == mint(cast(uint) 3).val());
    assert(3 == mint(cast(long) 3).val());
    assert(3 == mint(cast(ulong) 3).val());
    assert(1 == mint(cast(byte)-10).val());
    assert(1 == mint(cast(short)-10).val());
    assert(1 == mint(cast(int)-10).val());
    assert(1 == mint(cast(long)-10).val());

    assert(2 == (cast(int)(1) + mint(1)).val());
    assert(2 == (cast(short)(1) + mint(1)).val());

    mint m;
    assert(0 == m.val());
}

unittest
{
    alias mint = StaticModInt!(11);
    assert(1 == mint(true).val());
    assert(3 == mint(cast(char) 3).val());
    assert(3 == mint(cast(dchar) 3).val());
    assert(3 == mint(cast(wchar) 3).val());
    assert(3 == mint(cast(byte) 3).val());
    assert(3 == mint(cast(ubyte) 3).val());
    assert(3 == mint(cast(short) 3).val());
    assert(3 == mint(cast(ushort) 3).val());
    assert(3 == mint(cast(int) 3).val());
    assert(3 == mint(cast(uint) 3).val());
    assert(3 == mint(cast(long) 3).val());
    assert(3 == mint(cast(ulong) 3).val());
    assert(1 == mint(cast(byte)-10).val());
    assert(1 == mint(cast(short)-10).val());
    assert(1 == mint(cast(int)-10).val());
    assert(1 == mint(cast(long)-10).val());

    assert(2 == (cast(int)(1) + mint(1)).val());
    assert(2 == (cast(short)(1) + mint(1)).val());

    mint m;
    assert(0 == m.val());
}

// --- modint ---

struct StaticModInt(int m) if (1 <= m)
{
    import std.traits : isSigned, isUnsigned, isSomeChar;

    alias mint = StaticModInt;
public:
    static int mod()
    {
        return m;
    }

    static mint raw(int v)
    {
        mint x;
        x._v = v;
        return x;
    }

    this(T)(T v) if (isSigned!T)
    {
        long x = cast(long)(v % cast(long)(umod()));
        if (x < 0)
            x += umod();
        _v = cast(uint)(x);
    }

    this(T)(T v) if (isUnsigned!T || isSomeChar!T)
    {
        _v = cast(uint)(v % umod());
    }

    this(bool v)
    {
        _v = cast(uint)(v) % umod();
    }

    auto opAssign(T)(T v)
            if (isSigned!T || isUnsigned!T || isSomeChar!T || is(T == bool))
    {
        return this = mint(v);
    }

    inout uint val() pure
    {
        return _v;
    }

    ref mint opUnary(string op)() pure nothrow @safe if (op == "++")
    {
        _v++;
        if (_v == umod())
            _v = 0;
        return this;
    }

    ref mint opUnary(string op)() pure nothrow @safe if (op == "--")
    {
        if (_v == 0)
            _v = umod();
        _v--;
        return this;
    }

    mint opUnary(string op)() if (op == "+" || op == "-")
    {
        mint x;
        return mixin("x " ~ op ~ " this");
    }

    ref mint opOpAssign(string op, T)(T value) if (!is(T == mint))
    {
        mint y = value;
        return opOpAssign!(op)(y);
    }

    ref mint opOpAssign(string op, T)(T value) if (op == "+" && is(T == mint))
    {
        _v += value._v;
        if (_v >= umod())
            _v -= umod();
        return this;
    }

    ref mint opOpAssign(string op, T)(T value) if (op == "-" && is(T == mint))
    {
        _v -= value._v;
        if (_v >= umod())
            _v += umod();
        return this;
    }

    ref mint opOpAssign(string op, T)(T value) if (op == "*" && is(T == mint))
    {
        ulong z = _v;
        z *= value._v;
        _v = cast(uint)(z % umod());
        return this;
    }

    ref mint opOpAssign(string op, T)(T value) if (op == "/" && is(T == mint))
    {
        return this = this * value.inv();
    }

    mint pow(long n) const pure
    {
        assert(0 <= n);
        mint x = this, r = 1;
        while (n)
        {
            if (n & 1)
                r *= x;
            x *= x;
            n >>= 1;
        }
        return r;
    }

    mint inv() const pure
    {
        static if (prime)
        {
            assert(_v);
            return pow(umod() - 2);
        }
        else
        {
            auto eg = invGcd(_v, mod());
            assert(eg[0] == 1);
            return mint(eg[1]);
        }
    }

    mint opBinary(string op, R)(const R value) const pure 
            if (op == "+" || op == "-" || op == "*" || op == "/")
    {
        static if (is(R == mint))
        {
            mint x;
            x += this;
            return x.opOpAssign!(op)(value);
        }
        else
        {
            mint y = value;
            return opOpAssign!(op)(y);
        }
    }

    mint opBinaryRight(string op, L)(const L value) const if (!is(L == mint))
    {
        mint y = value;
        return y.opBinary!(op)(this);
    }

    bool opEquals(R)(const R value) const
    {
        static if (is(R == mint))
        {
            return _v == value._v;
        }
        else
        {
            mint y = mint(value);
            return this == y;
        }
    }

private:
    uint _v;
    uint umod() pure const
    {
        return m;
    }

    enum bool prime = isPrime!(m);
}

struct DynamicModInt(int id)
{
    import std.traits : isSigned, isUnsigned, isSomeChar;

    alias mint = DynamicModInt;
public:
    static int mod()
    {
        return bt.umod();
    }

    static void setMod(int m)
    {
        assert(1 <= m);
        bt = Barrett(m);
    }

    static mint raw(int v)
    {
        mint x;
        x._v = v;
        return x;
    }

    this(T)(T v) if (isSigned!T)
    {
        long x = cast(long)(v % cast(long)(umod()));
        if (x < 0)
            x += umod();
        _v = cast(uint)(x);
    }

    this(T)(T v) if (isUnsigned!T || isSomeChar!T)
    {
        _v = cast(uint)(v % umod());
    }

    this(bool v)
    {
        _v = cast(uint)(v) % umod();
    }

    auto opAssign(T)(T v)
            if (isSigned!T || isUnsigned!T || isSomeChar!T || is(T == bool))
    {
        return this = mint(v);
    }

    inout uint val()
    {
        return _v;
    }

    ref mint opUnary(string op)() nothrow @safe if (op == "++")
    {
        _v++;
        if (_v == umod())
            _v = 0;
        return this;
    }

    ref mint opUnary(string op)() nothrow @safe if (op == "--")
    {
        if (_v == 0)
            _v = umod();
        _v--;
        return this;
    }

    mint opUnary(string op)() if (op == "+" || op == "-")
    {
        mint x;
        return mixin("x " ~ op ~ " this");
    }

    ref mint opOpAssign(string op, T)(T value) if (!is(T == mint))
    {
        mint y = value;
        return opOpAssign!(op)(y);
    }

    ref mint opOpAssign(string op, T)(T value) if (op == "+" && is(T == mint))
    {
        _v += value._v;
        if (_v >= umod())
            _v -= umod();
        return this;
    }

    ref mint opOpAssign(string op, T)(T value) if (op == "-" && is(T == mint))
    {
        _v -= value._v;
        if (_v >= umod())
            _v += umod();
        return this;
    }

    ref mint opOpAssign(string op, T)(T value) if (op == "*" && is(T == mint))
    {
        _v = bt.mul(_v, value._v);
        return this;
    }

    ref mint opOpAssign(string op, T)(T value) if (op == "/" && is(T == mint))
    {
        return this = this * value.inv();
    }

    mint pow(long n) const
    {
        assert(0 <= n);
        mint x = this, r = 1;
        while (n)
        {
            if (n & 1)
                r *= x;
            x *= x;
            n >>= 1;
        }
        return r;
    }

    mint inv() const
    {
        auto eg = invGcd(_v, mod());
        assert(eg[0] == 1);
        return mint(eg[1]);
    }

    mint opBinary(string op, R)(const R value)
            if (op == "+" || op == "-" || op == "*" || op == "/")
    {
        static if (is(R == mint))
        {
            mint x;
            x += this;
            return x.opOpAssign!(op)(value);
        }
        else
        {
            mint y = value;
            return opOpAssign!(op)(y);
        }
    }

    mint opBinaryRight(string op, L)(const L value) const if (!is(L == mint))
    {
        mint y = value;
        return y.opBinary!(op)(this);
    }

    bool opEquals(R)(const R value) const
    {
        static if (is(R == mint))
        {
            return _v == value._v;
        }
        else
        {
            mint y = mint(value);
            return this == y;
        }
    }

private:
    uint _v;
    static Barrett bt = Barrett(998_244_353);
    uint umod()
    {
        return bt.umod();
    }
}

alias modint998244353 = StaticModInt!(998244353);
alias modint1000000007 = StaticModInt!(1000000007);
alias modint = DynamicModInt!(-1);
