using VHDL.type;
using VHDL.declaration;

namespace VHDLParser.typeinfer
{
    class TypeHelper : ISubtypeIndicationVisitor
    {
        private ISubtypeIndication baseType;

        public static ISubtypeIndication GetBaseType(ISubtypeIndication type)
        {
            var getter = new TypeHelper();
            type.accept(getter);
            return getter.baseType;
        }

        public static string GetTypeName(ISubtypeIndication indication)
        {
            var type = indication as Type;
            if (type != null)
                return type.Identifier;
            return "";
        }

        public virtual void visit(Subtype item)
        {
            item.SubtypeIndication.accept(this);
        }

        public virtual void visit(ResolvedSubtypeIndication item)
        {
            item.BaseType.accept(this);
        }

        public virtual void visit(Type item)
        {
            baseType = item;
        }


        public void visit(IndexSubtypeIndication item)
        {
            throw new System.NotImplementedException();
        }

        public void visit(RangeSubtypeIndication item)
        {
            throw new System.NotImplementedException();
        }

        public void visit(UnresolvedType item)
        {
            throw new System.NotImplementedException();
        }
    }
}
