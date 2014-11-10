using VHDL.expression;
using VHDL.Object;
using VHDL.type;

namespace VHDLParser.typeinfer
{
    class ExpressionInference : ExpressionVisitor
    {
        private TypeInference baseInfer;

        public ExpressionInference(TypeInference baseInfer)
        {
            this.baseInfer = baseInfer;
        }

        protected override void visitLiteral(Literal expression)
        {
            var literalInfer = new LiteralInference(baseInfer);
            expression.accept(literalInfer);
        }

        protected override void visitName(Name name)
        {
            var arrElem = name as ArrayElement;
            if (arrElem != null)
            {
            }

            var recElem = name as RecordElement;
            if (recElem != null)
            {
                string expectedName = TypeHelper.GetTypeName(baseInfer.ExpectedType);
                if (expectedName != "" && expectedName == TypeHelper.GetTypeName(recElem.Type))
                    baseInfer.ResultType = recElem.Type as Type;
            }
        }
    }
}
