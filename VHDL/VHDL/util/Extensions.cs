using System;

namespace VHDL.util
{
    public static class Extensions
    {
        public static bool EqualsIgnoreCase(this String lhs, String rhs)
        {
            return lhs.Equals(rhs, StringComparison.InvariantCultureIgnoreCase);
        }

        public static int CompareToIgnoreCase(this String lhs, String rhs)
        {
            return String.Compare(rhs, lhs, StringComparison.InvariantCultureIgnoreCase);
        }
    }
}
