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

// --- modint ---

struct StaticModInt(int m) if (1 <= m)
{
    import std.traits : isSigned, isUnsigned;

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

    this(T)(T v) if (isUnsigned!T)
    {
        _v = cast(uint)(v % umod());
    }

    this(bool v)
    {
        _v = cast(uint)(v) % umod();
    }

    uint val()
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

    mint opBinary(string op, R)(const R value) const 
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
    import std.traits : isSigned, isUnsigned;

    alias mint = DynamicModInt;
public:
    static int mod()
    {
        return _m;
    }

    static void setMod(int m)
    {
        assert(1 <= m);
        _m = m;
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

    this(T)(T v) if (isUnsigned!T)
    {
        _v = cast(uint)(v % umod());
    }

    this(bool v)
    {
        _v = cast(uint)(v) % umod();
    }

    uint val()
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
        ulong z = _v;
        z *= value._v;
        _v = cast(uint)(z % umod());
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

    mint opBinary(string op, R)(const R value) const 
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
    static uint _m;
    uint umod()
    {
        return _m;
    }
}

alias modint998244353 = StaticModInt!(998244353);
alias modint1000000007 = StaticModInt!(1000000007);
alias modint = DynamicModInt!(-1);