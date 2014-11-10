//
//  Copyright (C) 2010-2014  Denis Gavrish
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using VHDL.literal;
using VHDL.expression;

namespace VHDL.parser.antlr
{
    public class Part
    {

        private readonly TypeEnum type;
        private StringLiteral literal;
        private string identifier;
        private Expression expression;
        private Signature signature;
        private List<Expression> indices;
        private string suffix;
        private DiscreteRange range;
        private List<AssociationElement> associationList;

        private Part(TypeEnum type)
        {
            this.type = type;
        }

        public static Part CreateOperatorSymbol(StringLiteral literal)
        {
            Part part = new Part(TypeEnum.OPERATOR_SYMBOL);
            part.literal = literal;
            return part;
        }

        public static Part CreateAttribute(string identifier, Expression expression, Signature signature)
        {
            Part part = new Part(TypeEnum.ATTRIBUTE);
            part.identifier = identifier;
            part.expression = expression;
            part.signature = signature;
            return part;
        }

        public static Part CreateIndexed(List<Expression> indices)
        {
            Part part = new Part(TypeEnum.INDEXED);
            part.indices = indices;
            return part;
        }

        public static Part CreateSelected(string suffix)
        {
            Part part = new Part(TypeEnum.SELECTED);
            part.suffix = suffix;
            return part;
        }

        public static Part CreateSlice(DiscreteRange range)
        {
            Part part = new Part(TypeEnum.SLICE);
            part.range = range;
            return part;
        }

        public static Part CreateAssociation(List<AssociationElement> associationList)
        {
            Part part = new Part(TypeEnum.ASSOCIATION);
            part.associationList = associationList;
            return part;
        }

        public virtual TypeEnum Type
        {
            get { return type; }
        }

        public virtual StringLiteral Literal
        {
            get { return literal; }
        }

        public virtual Expression getExpression()
        {
            return expression;
        }

        public virtual string getIdentifier()
        {
            return identifier;
        }

        public virtual Signature getSignature()
        {
            return signature;
        }

        public virtual List<Expression> getIndices()
        {
            return indices;
        }

        public virtual string getSuffix()
        {
            return suffix;
        }

        public virtual List<AssociationElement> getAssociationList()
        {
            return associationList;
        }

        public virtual DiscreteRange getRange()
        {
            return range;
        }

        public enum TypeEnum
        {
            OPERATOR_SYMBOL,
            ATTRIBUTE,
            INDEXED,
            SELECTED,
            SLICE,
            ASSOCIATION
        }

        public class PartList : IEnumerable<Part>
        {
            public int currentIndex { get; set; }
            private readonly ContinuousIterator iterator;
            private readonly List<Part> parts;

            public PartList()
            {
                iterator = new ContinuousIterator(this);
                parts = new List<Part>();
                currentIndex = 0;
            }

            public virtual int remainingParts()
            {
                return parts.Count - currentIndex - 1;
            }

            public virtual void Add(Part part)
            {
                parts.Add(part);
            }

            public virtual void resetContinuousIterator()
            {
                currentIndex = 0;
            }

            public Part Element
            {
                get
                { return parts[currentIndex]; }
            }

            public ContinuousIterator Iterator()
            {
                return iterator;
            }

            public virtual bool finished()
            {
                return true;//remainingParts() == 0;
            }

            public class ContinuousIterator
            {
                private PartList parent;
                public ContinuousIterator(PartList parent)
                {
                    this.parent = parent;
                }

                public bool hasNext()
                {
                    return parent.remainingParts() > 0;
                }

                public Part next()
                {
                    if (hasNext())
                    {
                        parent.currentIndex++;
                        return parent.parts[parent.currentIndex];
                    }
                    else
                    {
                        throw new Exception("No Such Elements");
                    }
                }

                public void remove()
                {
                    throw new NotImplementedException();
                }
            }

            #region IEnumerable<Part> Members

            public IEnumerator<Part> GetEnumerator()
            {
                foreach (var p in parts)
                    yield return p;
            }

            #endregion

            #region IEnumerable Members

            System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
            {
                foreach (var p in parts)
                    yield return p;
            }

            #endregion
        }

    }
}
