module acl.string;

int[] sa_naive(int[] s)
{
    import std.range : iota;
    import std.array : array;
    import std.algorithm : sort;

    int n = cast(int)(s.length);
    int[] sa = iota(n).array;
    sort!((int l, int r) { return s[l .. $] < s[r .. $]; })(sa);
    return sa;
}

int[] lcp_naive(int[] s, int[] sa)
{
    int n = cast(int) s.length;
    assert(n);
    auto lcp = new int[](n - 1);
    foreach (i; 0 .. n - 1)
    {
        int l = sa[i], r = sa[i + 1];
        while (l + lcp[i] < n && r + lcp[i] < n && s[l + lcp[i]] == s[r + lcp[i]])
            lcp[i]++;
    }
    return lcp;
}

int[] z_naive(int[] s)
{
    int n = cast(int) s.length;
    auto z = new int[](n);
    foreach (i; 0 .. n)
        while (i + z[i] < n && s[z[i]] == s[i + z[i]])
            z[i]++;
    return z;
}

unittest
{
    assert([] == suffixArray(""));
    assert([] == suffixArray(cast(int[])[]));

    assert([] == zAlgorithm(""));
    assert([] == zAlgorithm(cast(int[])[]));
}

unittest
{
    import std.algorithm : max;

    foreach (n; 1 .. 5 + 1)
    {
        int m = 1;
        foreach (i; 0 .. n)
            m *= 4;
        foreach (f; 0 .. m)
        {
            auto s = new int[](n);
            int g = f;
            int max_c = 0;
            foreach (i; 0 .. n)
            {
                s[i] = g % 4;
                max_c = max(max_c, s[i]);
                g /= 4;
            }
            auto sa = sa_naive(s);
            assert(sa == suffixArray(s));
            assert(sa == suffixArray(s, max_c));
            assert(lcp_naive(s, sa) == lcpArray(s, sa));
        }
    }
    foreach (n; 1 .. 10 + 1)
    {
        int m = 1;
        foreach (i; 0 .. n)
            m *= 2;
        foreach (f; 0 .. m)
        {
            auto s = new int[](n);
            int g = f;
            int max_c = 0;
            foreach (i; 0 .. n)
            {
                s[i] = g % 2;
                max_c = max(max_c, s[i]);
                g /= 2;
            }
            auto sa = sa_naive(s);
            assert(sa == suffixArray(s));
            assert(sa == suffixArray(s, max_c));
            assert(lcp_naive(s, sa) == lcpArray(s, sa));
        }
    }
}

unittest
{
    import std.algorithm : max;

    foreach (n; 1 .. 5 + 1)
    {
        int m = 1;
        foreach (i; 0 .. n)
            m *= 4;
        foreach (f; 0 .. m)
        {
            auto s = new int[](n);
            int g = f;
            int max_c = 0;
            foreach (i; 0 .. n)
            {
                s[i] = g % 4;
                max_c = max(max_c, s[i]);
                g /= 4;
            }
            auto sa = saNaive(s);
            assert(sa_naive(s) == sa);
        }
    }
    foreach (n; 1 .. 10 + 1)
    {
        int m = 1;
        foreach (i; 0 .. n)
            m *= 2;
        foreach (f; 0 .. m)
        {
            auto s = new int[](n);
            int g = f;
            int max_c = 0;
            foreach (i; 0 .. n)
            {
                s[i] = g % 2;
                max_c = max(max_c, s[i]);
                g /= 2;
            }
            auto sa = saNaive(s);
            assert(sa_naive(s) == sa);
        }
    }
}

unittest
{
    import std.algorithm : max;

    foreach (n; 1 .. 5 + 1)
    {
        int m = 1;
        foreach (i; 0 .. n)
            m *= 4;
        foreach (f; 0 .. m)
        {
            auto s = new int[](n);
            int g = f;
            int max_c = 0;
            foreach (i; 0 .. n)
            {
                s[i] = g % 4;
                max_c = max(max_c, s[i]);
                g /= 4;
            }
            auto sa = saDoubling(s);
            assert(sa_naive(s) == sa);
        }
    }
    foreach (n; 1 .. 10 + 1)
    {
        int m = 1;
        foreach (i; 0 .. n)
            m *= 2;
        foreach (f; 0 .. m)
        {
            auto s = new int[](n);
            int g = f;
            int max_c = 0;
            foreach (i; 0 .. n)
            {
                s[i] = g % 2;
                max_c = max(max_c, s[i]);
                g /= 2;
            }
            auto sa = saDoubling(s);
            assert(sa_naive(s) == sa);
        }
    }
}

unittest
{
    import std.algorithm : max;

    foreach (n; 1 .. 5 + 1)
    {
        int m = 1;
        foreach (i; 0 .. n)
            m *= 4;
        foreach (f; 0 .. m)
        {
            auto s = new int[](n);
            int g = f;
            int max_c = 0;
            foreach (i; 0 .. n)
            {
                s[i] = g % 4;
                max_c = max(max_c, s[i]);
                g /= 4;
            }
            auto sa = saIs!(-1, -1)(s, max_c);
            assert(sa_naive(s) == sa);
        }
    }
    foreach (n; 1 .. 10 + 1)
    {
        int m = 1;
        foreach (i; 0 .. n)
            m *= 2;
        foreach (f; 0 .. m)
        {
            auto s = new int[](n);
            int g = f;
            int max_c = 0;
            foreach (i; 0 .. n)
            {
                s[i] = g % 2;
                max_c = max(max_c, s[i]);
                g /= 2;
            }
            auto sa = saIs!(-1, -1)(s, max_c);
            assert(sa_naive(s) == sa);
        }
    }
}

unittest
{
    foreach (n; 1 .. 100 + 1)
    {
        auto s = new int[](n);
        s[] = 10;
        assert(sa_naive(s) == suffixArray(s));
        assert(sa_naive(s) == suffixArray(s, 10));
        assert(sa_naive(s) == suffixArray(s, 12));
    }
}

unittest
{
    foreach (n; 1 .. 100 + 1)
    {
        auto s = new int[](n);
        foreach (i; 0 .. n)
            s[i] = i % 2;
        assert(sa_naive(s) == suffixArray(s));
        assert(sa_naive(s) == suffixArray(s, 3));
    }
    foreach (n; 1 .. 100 + 1)
    {
        auto s = new int[](n);
        foreach (i; 0 .. n)
            s[i] = 1 - (i % 2);
        assert(sa_naive(s) == suffixArray(s));
        assert(sa_naive(s) == suffixArray(s, 3));
    }
}

unittest
{
    string s = "missisippi";
    int[] sa = suffixArray(s);
    string[] answer = [
        "i", "ippi", "isippi", "issisippi", "missisippi", "pi", "ppi", "sippi",
        "sisippi", "ssisippi",
    ];
    assert(sa.length == answer.length);
    foreach (i; 0 .. sa.length)
        assert(s[sa[i] .. $] == answer[i]);
}

unittest
{
    assert([0] == suffixArray([0]));
    assert([0] == suffixArray([-1]));
    assert([0] == suffixArray([1]));
    assert([0] == suffixArray([int.min]));
    assert([0] == suffixArray([int.max]));
}

unittest
{
    string s = "aab";
    auto sa = suffixArray(s);
    assert([0, 1, 2] == sa);
    auto lcp = lcpArray(s, sa);
    assert([1, 0] == lcp);

    assert(lcp == lcpArray([0, 0, 1], sa));
    assert(lcp == lcpArray([-100, -100, 100], sa));
    assert(lcp == lcpArray([int.min, int.min, int.max], sa));

    assert(lcp == lcpArray([long.min, long.min, long.max], sa));
    assert(lcp == lcpArray([uint.min, uint.min, uint.max], sa));
    assert(lcp == lcpArray([ulong.min, ulong.min, ulong.max], sa));
}

unittest
{
    string s = "abab";
    auto z = zAlgorithm(s);
    assert([4, 0, 2, 0] == z);
    assert([4, 0, 2, 0] == zAlgorithm([1, 10, 1, 10]));
    assert(z_naive([0, 0, 0, 0, 0, 0, 0]) == zAlgorithm([0, 0, 0, 0, 0, 0, 0]));
}

unittest
{
    foreach (n; 1 .. 6 + 1)
    {
        int m = 1;
        foreach (i; 0 .. n)
            m *= 4;
        foreach (f; 0 .. m)
        {
            auto s = new int[](n);
            int g = f;
            foreach (i; 0 .. n)
            {
                s[i] = g % 4;
                g /= 4;
            }
            assert(z_naive(s) == zAlgorithm(s));
        }
    }
    foreach (n; 1 .. 10 + 1)
    {
        int m = 1;
        foreach (i; 0 .. n)
            m *= 2;
        foreach (f; 0 .. m)
        {
            auto s = new int[](n);
            int g = f;
            foreach (i; 0 .. n)
            {
                s[i] = g % 2;
                g /= 2;
            }
            assert(z_naive(s) == zAlgorithm(s));
        }
    }
}

// --- string ---

int[] saNaive(const ref int[] s) @safe pure nothrow
{
    import std.range : iota, array;
    import std.algorithm : sort;

    int n = cast(int) s.length;
    auto sa = iota(n).array;
    bool less(int l, int r)
    {
        if (l == r)
            return false;
        while (l < n && r < n)
        {
            if (s[l] != s[r])
                return s[l] < s[r];
            l++;
            r++;
        }
        return l == n;
    }

    sort!(less)(sa);
    return sa;
}

int[] saDoubling(const ref int[] s) @safe pure nothrow
{
    import std.range : iota, array;
    import std.algorithm : sort, swap;

    int n = cast(int) s.length;
    auto sa = iota(n).array;
    auto rnk = s.dup;
    auto tmp = new int[](n);

    for (int k = 1; k < n; k *= 2)
    {
        bool less(int x, int y)
        {
            if (rnk[x] != rnk[y])
                return rnk[x] < rnk[y];
            int rx = x + k < n ? rnk[x + k] : -1;
            int ry = y + k < n ? rnk[y + k] : -1;
            return rx < ry;
        }

        sort!(less)(sa);
        tmp[sa[0]] = 0;
        foreach (i; 1 .. n)
            tmp[sa[i]] = tmp[sa[i - 1]] + (less(sa[i - 1], sa[i]) ? 1 : 0);
        swap(tmp, rnk);
    }
    return sa;
}

int[] saIs(int THRESHOLD_NAIVE = 10, int THRESHOLD_DOUBLING = 40)(int[] s, int upper)
{
    int n = cast(int) s.length;
    if (n == 0)
        return [];
    if (n == 1)
        return [0];
    if (n == 2)
    {
        if (s[0] < s[1])
        {
            return [0, 1];
        }
        else
        {
            return [1, 0];
        }
    }
    if (n < THRESHOLD_NAIVE)
        return saNaive(s);
    if (n < THRESHOLD_DOUBLING)
        return saDoubling(s);
    auto sa = new int[](n);
    auto ls = new bool[](n);
    foreach_reverse (i; 0 .. n - 2 + 1)
        ls[i] = (s[i] == s[i + 1]) ? ls[i + 1] : (s[i] < s[i + 1]);
    auto sum_l = new int[](upper + 1);
    auto sum_s = new int[](upper + 1);
    foreach (i; 0 .. n)
    {
        if (!ls[i])
        {
            sum_s[s[i]]++;
        }
        else
        {
            sum_l[s[i] + 1]++;
        }
    }
    foreach (i; 0 .. upper + 1)
    {
        sum_s[i] += sum_l[i];
        if (i < upper)
            sum_l[i + 1] += sum_s[i];
    }
    void induce(const ref int[] lms)
    {
        sa[] = -1;
        auto buf = new int[](upper + 1);
        buf[] = sum_s[];
        foreach (d; lms)
        {
            if (d == n)
                continue;
            sa[buf[s[d]]++] = d;
        }
        buf[] = sum_l[];
        sa[buf[s[n - 1]]++] = n - 1;
        foreach (i; 0 .. n)
        {
            int v = sa[i];
            if (1 <= v && !ls[v - 1])
                sa[buf[s[v - 1]]++] = v - 1;
        }
        buf[] = sum_l[];
        foreach_reverse (i; 0 .. n)
        {
            int v = sa[i];
            if (v >= 1 && ls[v - 1])
            {
                sa[--buf[s[v - 1] + 1]] = v - 1;
            }
        }
    }

    auto lms_map = new int[](n + 1);
    lms_map[] = -1;
    int m = 0;
    foreach (i; 1 .. n)
        if (!ls[i - 1] && ls[i])
            lms_map[i] = m++;
    int[] lms;
    lms.reserve(m);
    foreach (i; 1 .. n)
        if (!ls[i - 1] && ls[i])
            lms ~= i;

    induce(lms);

    if (m)
    {
        int[] sorted_lms;
        sorted_lms.reserve(m);
        foreach (int v; sa)
            if (lms_map[v] != -1)
                sorted_lms ~= v;
        auto rec_s = new int[](m);
        int rec_upper = 0;
        rec_s[lms_map[sorted_lms[0]]] = 0;
        foreach (i; 1 .. m)
        {
            int l = sorted_lms[i - 1];
            int r = sorted_lms[i];
            int end_l = (lms_map[l] + 1 < m) ? lms[lms_map[l] + 1] : n;
            int end_r = (lms_map[r] + 1 < m) ? lms[lms_map[r] + 1] : n;
            bool same = true;
            if (end_l - l != end_r - r)
            {
                same = false;
            }
            else
            {
                while (l < end_l)
                {
                    if (s[l] != s[r])
                        break;
                    l++;
                    r++;
                }
                if (l == n || s[l] != s[r])
                    same = false;
            }
            if (!same)
                rec_upper++;
            rec_s[lms_map[sorted_lms[i]]] = rec_upper;
        }
        auto rec_sa = saIs!(THRESHOLD_NAIVE, THRESHOLD_DOUBLING)(rec_s, rec_upper);
        foreach (i; 0 .. m)
            sorted_lms[i] = lms[rec_sa[i]];
        induce(sorted_lms);
    }
    return sa;
}

int[] suffixArray(int[] s, int upper) @safe pure nothrow
{
    assert(0 <= upper);
    foreach (int d; s)
        assert(0 <= d && d <= upper);
    auto sa = saIs(s, upper);
    return sa;
}

int[] suffixArray(T)(T[] s)
{
    import std.range : iota;
    import std.array : array;
    import std.algorithm : sort;

    int n = cast(int) s.length;
    int[] idx = iota(n).array;
    sort!((int l, int r) => s[l] < s[r])(idx);
    auto s2 = new int[](n);
    int now = 0;
    foreach (i; 0 .. n)
    {
        if (i && s[idx[i - 1]] != s[idx[i]])
            now++;
        s2[idx[i]] = now;
    }
    return saIs(s2, now);
}

int[] suffixArray(string s) @safe pure nothrow
{
    int n = cast(int) s.length;
    auto s2 = new int[](n);
    foreach (i; 0 .. n)
        s2[i] = s[i];
    return saIs(s2, 255);
}

int[] lcpArray(T)(T[] s, int[] sa)
{
    int n = cast(int) s.length;
    assert(n >= 1);
    auto rnk = new int[](n);
    foreach (i; 0 .. n)
        rnk[sa[i]] = i;
    auto lcp = new int[](n - 1);
    int h = 0;
    foreach (i; 0 .. n)
    {
        if (h > 0)
            h--;
        if (rnk[i] == 0)
            continue;
        int j = sa[rnk[i] - 1];
        for (; j + h < n && i + h < n; h++)
            if (s[j + h] != s[i + h])
                break;
        lcp[rnk[i] - 1] = h;
    }
    return lcp;
}

int[] lcpArray(string s, int[] sa) @safe pure nothrow
{
    int n = cast(int) s.length;
    auto s2 = new int[](n);
    foreach (i; 0 .. n)
        s2[i] = s[i];
    return lcpArray(s2, sa);
}

int[] zAlgorithm(T)(T[] s)
{
    import std.algorithm : min;

    int n = cast(int) s.length;
    if (n == 0)
        return [];
    auto z = new int[](n);
    int j;
    foreach (i; 1 .. n)
    {
        z[i] = (j + z[j] < i) ? 0 : min(j + z[j] - i, z[i - j]);
        while (i + z[i] < n && s[z[i]] == s[i + z[i]])
            z[i]++;
        if (j + z[j] < i + z[i])
            j = i;
    }
    z[0] = n;
    return z;
}

int[] zAlgorithm(string s) @safe pure nothrow
{
    int n = cast(int) s.length;
    auto s2 = new int[](n);
    foreach (i; 0 .. n)
    {
        s2[i] = s[i];
    }
    return zAlgorithm(s2);
}
