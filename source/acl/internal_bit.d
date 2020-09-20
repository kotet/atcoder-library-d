module acl.internal_bit;

unittest
{
    assert(0 == celiPow2(0));
    assert(0 == celiPow2(1));
    assert(1 == celiPow2(2));
    assert(2 == celiPow2(3));
    assert(2 == celiPow2(4));
    assert(3 == celiPow2(5));
    assert(3 == celiPow2(6));
    assert(3 == celiPow2(7));
    assert(3 == celiPow2(8));
    assert(4 == celiPow2(9));
    assert(30 == celiPow2(1 << 30));
    assert(31 == celiPow2((1 << 30) + 1));
    assert(31 == celiPow2(int.max));
}

unittest
{
    import core.bitop : bsf;

    assert(0 == bsf(1));
    assert(1 == bsf(2));
    assert(0 == bsf(3));
    assert(2 == bsf(4));
    assert(0 == bsf(5));
    assert(1 == bsf(6));
    assert(0 == bsf(7));
    assert(3 == bsf(8));
    assert(0 == bsf(9));
    assert(30 == bsf(1UL << 30));
    assert(0 == bsf((1UL << 31) - 1));
    assert(31 == bsf(1UL << 31));
    assert(0 == bsf(uint.max));
}

// --- internal_bit ---

int celiPow2(int n) @safe pure nothrow @nogc
{
    int x = 0;
    while ((1u << x) < cast(uint)(n))
        x++;
    return x;
}
