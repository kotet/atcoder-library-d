module acl.internal_bit;

// --- internal_bit ---

int celiPow2(int n)
{
    int x = 0;
    while ((1u << x) < cast(uint)(n))
        x++;
    return x;
}
