using VHDL.Object;

namespace VHDL.expression
{
    public class NameVisitor
    {
        public virtual void visit(VhdlObject name)
        {
        }

        public virtual void visit(Slice name)
        {
        }

        public virtual void visit(RecordElement name)
        {
        }

        public virtual void visit(AttributeExpression name)
        {
        }

        public virtual void visit(ArrayElement name)
        {
        }

        public virtual void visit(FunctionCall name)
        {
        }
    }
}
