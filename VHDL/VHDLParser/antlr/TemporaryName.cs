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

using System.Collections.Generic;

namespace VHDL.parser.antlr
{

    using AssociationElement = VHDL.AssociationElement;
    using DeclarativeRegion = VHDL.IDeclarativeRegion;
    using DiscreteRange = VHDL.DiscreteRange;
    using NamedEntity = VHDL.INamedEntity;
    using RangeAttributeName = VHDL.RangeAttributeName;
    using RangeProvider = VHDL.RangeProvider;
    using Signature = VHDL.Signature;
    using SubtypeDiscreteRange = VHDL.SubtypeDiscreteRange;
    using Standard = VHDL.builtin.Standard;
    using Attribute = VHDL.declaration.Attribute;
    using Component = VHDL.declaration.Component;
    using Function = VHDL.declaration.IFunction;
    using Expression = VHDL.expression.Expression;
    using FunctionCall = VHDL.expression.FunctionCall;
    using Name = VHDL.expression.Name;
    using Primary = VHDL.expression.Primary;
    using TypeConversion = VHDL.expression.TypeConversion;
    using Configuration = VHDL.libraryunit.Configuration;
    using Entity = VHDL.libraryunit.Entity;
    using EnumerationLiteral = VHDL.literal.EnumerationLiteral;
    using PhysicalLiteral = VHDL.literal.PhysicalLiteral;
    using StringLiteral = VHDL.literal.StringLiteral;
    using AttributeExpression = VHDL.Object.AttributeExpression;
    using Signal = VHDL.Object.Signal;
    using Variable = VHDL.Object.Variable;
    using SignalAssignmentTarget = VHDL.Object.ISignalAssignmentTarget;
    using VariableAssignmentTarget = VHDL.Object.IVariableAssignmentTarget;
    using VhdlObject = VHDL.Object.VhdlObject;
    using Type = VHDL.parser.ParseError.ParseErrorTypeEnum;
    using EnumerationType = VHDL.type.EnumerationType;
    using IndexSubtypeIndication = VHDL.type.IndexSubtypeIndication;
    using RangeSubtypeIndication = VHDL.type.RangeSubtypeIndication;
    using SubtypeIndication = VHDL.type.ISubtypeIndication;
    using Antlr.Runtime.Tree;
    using System;
    using VHDL.declaration;
    using VHDLParser;
    using TypeInference = VHDLParser.typeinfer.TypeInference;

    ///
    // * Temporary name used during meta class generation.
    // 
    internal class TemporaryName
    {

        private readonly Part.PartList parts = new Part.PartList();
        private readonly MetaClassCreator mcc;
        private readonly ITree tree;
        private static Name currentAssignTarget;

        public TemporaryName(MetaClassCreator mcc, ITree tree, StringLiteral stringLiteral)
        {
            this.mcc = mcc;
            this.tree = tree;
            parts.Add(Part.CreateOperatorSymbol(stringLiteral));
        }

        public TemporaryName(MetaClassCreator mcc, ITree tree, string prefix)
        {
            this.mcc = mcc;
            this.tree = tree;
            parts.Add(Part.CreateSelected(prefix));
        }

        public virtual void AddPart(Part part)
        {
            parts.Add(part);
        }

        //used only for error reporting
        private string toIdentifier()
        {
            parts.resetContinuousIterator();

            System.Text.StringBuilder selectedName = new System.Text.StringBuilder();

            bool first = true;
            foreach (Part part in parts)
            {
                if (part.Type == Part.TypeEnum.SELECTED)
                {
                    if (first)
                    {
                        first = false;
                    }
                    else
                    {
                        selectedName.Append('.');
                    }
                    selectedName.Append(part.getSuffix());
                }
                else
                {
                    parts.currentIndex--;
                    break;
                }
            }

            return (selectedName.Length == 0 ? "unknown" : selectedName.ToString());
        }

        private T resolve<T>(DeclarativeRegion scope) where T : class
        {
            var searcher = new ObjectSearcher(scope);
            return searcher.search(parts, o => o is T) as T;
        }

        // TODO: consider function declaration inside other function, etc.
        private List<T> resolveAll<T>(DeclarativeRegion scope) where T : class
        {
            var searcher = new ObjectSearcher(scope);
            return searcher.searchAll(parts, o => o is T).ConvertAll<T>(new Converter<object, T>(x => x as T));
        }

        public virtual Entity toEntity(DeclarativeRegion scope)
        {
            Entity entity = resolve<Entity>(scope);
            if (parts.finished() && entity != null)
            {
                return entity;
            }
            else
            {
                string identifier = toIdentifier();
                mcc.resolveError(tree, Type.UNKNOWN_ENTITY, identifier);

                if (mcc.Settings.CreateDummyObjects)
                {
                    Entity dummy = new Entity(identifier);
                    //set parent to allow resolving of names in architectures
                    dummy.Parent = scope;
                    return dummy;
                }
                else
                {
                    return null;
                }
            }
        }

        public virtual Configuration toConfiguration(DeclarativeRegion scope)
        {
            Configuration configuration = resolve<Configuration>(scope);
            if (parts.finished() && configuration != null)
            {
                return configuration;
            }
            else
            {
                string identifier = toIdentifier();
                mcc.resolveError(tree, Type.UNKNOWN_CONFIGURATION, identifier);

                if (mcc.Settings.CreateDummyObjects)
                {
                    return new Configuration(identifier, null, null);
                }
                else
                {
                    return null;
                }
            }
        }

        //TODO: don't use subtype indication
        public virtual SubtypeIndication toTypeMark(DeclarativeRegion scope)
        {
            SubtypeIndication type = resolve<SubtypeIndication>(scope);
            if (parts.finished() && type != null)
            {
                return type;
            }
            else
            {
                string identifier = toIdentifier();
                mcc.resolveError(tree, Type.UNKNOWN_TYPE, identifier);

                if (mcc.Settings.CreateDummyObjects)
                {
                    return new EnumerationType(identifier);
                }
                else
                {
                    return null;
                }
            }
        }

        public virtual Component toComponent(DeclarativeRegion scope)
        {
            Component component = resolve<Component>(scope);
            if (parts.finished() && component != null)
            {
                return component;
            }
            else
            {
                string identifier = toIdentifier();
                mcc.resolveError(tree, Type.UNKNOWN_COMPONENT, identifier);

                if (mcc.Settings.CreateDummyObjects)
                {
                    return new Component(identifier);
                }
                else
                {
                    return null;
                }
            }
        }

        public virtual Signal toSignal(DeclarativeRegion scope)
        {
            Signal signal = resolve<Signal>(scope);
            if (parts.finished() && signal != null)
            {
                return signal;
            }
            else
            {
                string identifier = toIdentifier();
                mcc.resolveError(tree, Type.UNKNOWN_SIGNAL, identifier);

                if (mcc.Settings.CreateDummyObjects)
                {
                    return new Signal(identifier, null);
                }
                else
                {
                    return null;
                }
            }
        }

        private string toSelectedName()
        {
            System.Text.StringBuilder selectedName = new System.Text.StringBuilder();

            bool first = true;
            foreach (Part part in parts)
            {
                if (part.Type == Part.TypeEnum.SELECTED)
                {
                    if (first)
                    {
                        first = false;
                    }
                    else
                    {
                        selectedName.Append('.');
                    }
                    selectedName.Append(part.getSuffix());
                }
                else
                {
                    return null;
                }
            }

            return (selectedName.Length == 0 ? null : selectedName.ToString());
        }

        //TODO: don't use string return value
        public virtual string toProcedure(DeclarativeRegion scope)
        {
            return toSelectedName();
        }

        //TODO: don't use a String
        public virtual string toFunction(DeclarativeRegion scope)
        {
            return toSelectedName();
        }

        private Name addTargetParts(Name obj, bool strict)
        {
            foreach (Part part in parts)
            {
                switch (part.Type)
                {
                    case Part.TypeEnum.ASSOCIATION:
                        List<Expression> indices = new List<Expression>();
                        foreach (AssociationElement element in part.getAssociationList())
                        {
                            indices.Add(element.Actual);
                        }
                        obj = obj.getArrayElement(indices);
                        break;

                    case Part.TypeEnum.INDEXED:
                        obj = obj.getArrayElement(part.getIndices());
                        break;

                    case Part.TypeEnum.SELECTED:
                        obj = obj.getRecordElement(part.getSuffix());
                        break;

                    case Part.TypeEnum.SLICE:
                        obj = obj.getSlice(part.getRange());
                        break;

                    default:
                        if (strict)
                        {
                            return null;
                        }
                        break;
                }
            }
            return obj;
        }

        public virtual SignalAssignmentTarget toSignalTarget(DeclarativeRegion scope)
        {
            Name obj = resolve<Signal>(scope);

            if (obj != null)
            {
                obj = addTargetParts(obj, true);
            }
            else
            {
                string identifier = toIdentifier();
                mcc.resolveError(tree, Type.UNKNOWN_SIGNAL_ASSIGNMENT_TARGET, identifier);

                if (mcc.Settings.CreateDummyObjects)
                {
                    Signal dummy = new Signal(identifier, null);
                    obj = addTargetParts(dummy, false);
                }
            }

            if (obj is SignalAssignmentTarget)
            {
                return (SignalAssignmentTarget)obj;
            }

            return null;
        }

        public virtual VariableAssignmentTarget toVariableTarget(DeclarativeRegion scope)
        {
            Name obj = resolve<Variable>(scope);

            if (obj != null)
            {
                obj = addTargetParts(obj, true);
            }
            else
            {
                string identifier = toIdentifier();
                mcc.resolveError(tree, Type.UNKNOWN_VARIABLE_ASSIGNMENT_TARGET, identifier);

                if (mcc.Settings.CreateDummyObjects)
                {
                    Variable dummy = new Variable(identifier, null);
                    obj = addTargetParts(dummy, false);
                }
            }

            currentAssignTarget = obj;

            if (obj is VariableAssignmentTarget)
            {
                return (VariableAssignmentTarget)obj;
            }

            return null;
        }

        public virtual string toUseClauseName(DeclarativeRegion scope)
        {
            return toSelectedName();
        }

        private Primary addPrimaryParts(Name obj)
        {
            foreach (Part part in parts)
            {
                switch (part.Type)
                {
                    case Part.TypeEnum.ASSOCIATION:
                        List<Expression> indices = new List<Expression>();
                        foreach (AssociationElement element in part.getAssociationList())
                        {
                            indices.Add(element.Actual);
                        }
                        obj = obj.getArrayElement(indices);
                        break;

                    case Part.TypeEnum.INDEXED:
                        obj = obj.getArrayElement(part.getIndices());
                        break;

                    case Part.TypeEnum.SELECTED:
                        obj = obj.getRecordElement(part.getSuffix());
                        break;

                    case Part.TypeEnum.SLICE:
                        obj = obj.getSlice(part.getRange());
                        break;

                    case Part.TypeEnum.ATTRIBUTE:
                        //TODO: remove dummy attribute
                        Attribute attrb = new Attribute(part.getIdentifier(), null);
                        obj = new AttributeExpression(obj, attrb, part.getExpression());
                        break;
                }
            }
            return obj;
        }

        public virtual Primary toPrimary(DeclarativeRegion scope, bool inElementAssociation)
        {
            //don't try to resolve simple names in choices inside an aggregate
            if (inElementAssociation)
            {
                if (parts.remainingParts() == 1)
                {
                    Part part = parts.Iterator().next();

                    if (part.Type == Part.TypeEnum.SELECTED)
                    {
                        //TODO: don't use dummy signal
                        return new Signal(part.getSuffix(), Standard.STRING);
                    }
                }
            }

            VhdlObject obj = resolve<VhdlObject>(scope);
            if (obj != null)
            {
                return addPrimaryParts(obj);
            }

            SubtypeIndication type = resolve<SubtypeIndication>(scope);
            if (type is NamedEntity)
            {
                if (parts.remainingParts() == 1)
                {
                    Part part = parts.Iterator().next();

                    switch (part.Type)
                    {
                        case Part.TypeEnum.ATTRIBUTE:
                            //TODO: remove dummy objects
                            string identifier = ((NamedEntity)type).Identifier;
                            Signal dummy = new Signal(identifier, null);
                            Attribute dummyAttrb = new Attribute(part.getIdentifier(), null);
                            return new AttributeExpression(dummy, dummyAttrb, part.getExpression());

                        case Part.TypeEnum.ASSOCIATION:
                            if (part.getAssociationList().Count == 1)
                            {
                                AssociationElement ae = part.getAssociationList()[0];
                                if (ae.Actual != null && ae.Formal == null)
                                {
                                    return new TypeConversion(type, ae.Actual);
                                }
                            }
                            break;

                        case Part.TypeEnum.INDEXED:
                            if (part.getIndices().Count == 1)
                            {
                                return new TypeConversion(type, part.getIndices()[0]);
                            }
                            break;
                    }
                }
            }

            var overloads = resolveAll<ISubprogram>(scope);
            if (overloads.Count != 0) // TODO: distinguish undeclared function from other cases
            {
                var args = getAssociationList();

                
                SubtypeIndication target_type = (currentAssignTarget != null) ? currentAssignTarget.Type : null;
                Function declaration = (Function)TypeInference.ResolveOverload(scope, overloads, args, target_type);
                FunctionCall call = new FunctionCall(declaration);
                currentAssignTarget = null; // don't need any more

                call.Parameters.AddRange(args);
                if (parts.remainingParts() == 0)
                    return call;
                else
                    return addPrimaryParts(call);
            }

            parts.resetContinuousIterator();
            if (parts.remainingParts() == 0)
            {
                Part part = parts.Element;
                switch (part.Type)
                {
                    case Part.TypeEnum.SELECTED:
                        //TODO: check overloading
                        object o = scope.Scope.resolve(part.getSuffix());
                        if (o is EnumerationLiteral)
                        {
                            return (EnumerationLiteral)o;
                        }
                        else if (o is PhysicalLiteral)
                        {
                            return (PhysicalLiteral)o;
                        }
                        break;

                    case Part.TypeEnum.OPERATOR_SYMBOL:
                        //TODO: this isn't always an operator symbol
                        return part.Literal;
                }
            }

            mcc.resolveError(tree, Type.UNKNOWN_OTHER, toIdentifier());
            if (mcc.Settings.CreateDummyObjects)
            {
                Signal dummy = new Signal(toIdentifier(), null);
                return addPrimaryParts(dummy);
            }
            else
            {
                return null;
            }
        }

        private RangeAttributeName toRangeAttributeName(string prefix)
        {
            if (parts.remainingParts() != 1)
            {
                return null;
            }

            Part part = parts.Iterator().next();

            if (part.Type == Part.TypeEnum.ATTRIBUTE)
            {
                //TODO: check other parameters of attribute part

                if (part.getIdentifier().Equals("range", System.StringComparison.InvariantCultureIgnoreCase))
                {
                    return new RangeAttributeName(prefix, RangeAttributeName.RangeAttributeNameType.RANGE, part.getExpression());
                }
                else if (part.getIdentifier().Equals("reverse_range", System.StringComparison.InvariantCultureIgnoreCase))
                {
                    return new RangeAttributeName(prefix, RangeAttributeName.RangeAttributeNameType.REVERSE_RANGE, part.getExpression());
                }
                else
                {
                    return null;
                }
            }
            else
            {
                return null;
            }
        }

        public virtual RangeProvider toRangeName(DeclarativeRegion scope)
        {
            RangeProvider range = resolveRangeName(scope);
            if (range != null)
            {
                return range;
            }

            string identifier = toIdentifier();
            mcc.resolveError(tree, Type.UNKNOWN_OTHER, identifier);
            if (mcc.Settings.CreateDummyObjects)
            {
                RangeAttributeName name = toRangeAttributeName(identifier);
                if (name != null)
                {
                    return name;
                }
                else
                {
                    return new RangeAttributeName(identifier, RangeAttributeName.RangeAttributeNameType.RANGE);
                }
            }
            else
            {
                return null;
            }
        }

        private RangeProvider resolveRangeName(DeclarativeRegion scope)
        {
            VhdlObject obj = resolve<VhdlObject>(scope);
            if (obj != null)
            {
                //parts.currentIndex = 1;
                return toRangeAttributeName(obj.Identifier);
            }

            SubtypeIndication subtype = resolve<SubtypeIndication>(scope);
            if (subtype is NamedEntity)
            {
                string identifier = ((NamedEntity)subtype).Identifier;
                return toRangeAttributeName(identifier);
            }
            else
            {
                return null;
            }
        }

        public virtual DiscreteRange toDiscreteRange(DeclarativeRegion scope)
        {
            RangeProvider range = resolveRangeName(scope);
            if (range != null)
            {
                return range;
            }

            SubtypeIndication subtype = resolve<SubtypeIndication>(scope);
            if (subtype != null && parts.finished())
            {
                return new SubtypeDiscreteRange(subtype);
            }

            string identifier = toIdentifier();
            mcc.resolveError(tree, Type.UNKNOWN_OTHER, identifier);

            if (mcc.Settings.CreateDummyObjects)
            {
                if (parts.remainingParts() == 1)
                {
                    Part part = parts.Iterator().next();

                    if (part.Type == Part.TypeEnum.ATTRIBUTE)
                    {
                        if (part.getIdentifier().Equals("range", System.StringComparison.InvariantCultureIgnoreCase))
                        {
                            return new RangeAttributeName(identifier, RangeAttributeName.RangeAttributeNameType.RANGE);
                        }
                        else if (part.getIdentifier().Equals("reverse_range", System.StringComparison.InvariantCultureIgnoreCase))
                        {
                            return new RangeAttributeName(identifier, RangeAttributeName.RangeAttributeNameType.REVERSE_RANGE);
                        }
                    }
                }

                return new SubtypeDiscreteRange(new EnumerationType(identifier));
            }
            else
            {
                return null;
            }
        }

        public virtual DiscreteRange toDiscreteRange(DeclarativeRegion scope, List<DiscreteRange> indices)
        {
            SubtypeIndication type = toTypeMark(scope);

            if (type != null)
            {
                return new SubtypeDiscreteRange(new IndexSubtypeIndication(type, indices));
            }
            else
            {
                return null;
            }
        }

        public virtual DiscreteRange toDiscreteRange(DeclarativeRegion scope, RangeProvider range)
        {
            SubtypeIndication type = toTypeMark(scope);

            if (type != null)
            {
                return new SubtypeDiscreteRange(new RangeSubtypeIndication(type, range));
            }
            else
            {
                return null;
            }
        }

        public static Part CreateIndexedOrSlicePart(TemporaryName name, DeclarativeRegion scope)
        {
            SubtypeIndication type = name.resolve<SubtypeIndication>(scope);
            if (type != null && name.parts.finished())
            {
                return Part.CreateSlice(new SubtypeDiscreteRange(type));
            }

            RangeProvider range = name.resolveRangeName(scope);
            if (range != null)
            {
                return Part.CreateSlice(range);
            }

            return Part.CreateIndexed(new List<Expression>(new Expression[] { name.toPrimary(scope, false) }));
        }

        private List<AssociationElement> getAssociationList()
        {
            List<AssociationElement> result = new List<AssociationElement>();

            if (parts.remainingParts() != 0)
            {
                Part part = parts.Iterator().next();
                switch (part.Type)
                {
                    case Part.TypeEnum.ASSOCIATION:
                        result = part.getAssociationList();
                        break;

                    case Part.TypeEnum.INDEXED:
                        result = new List<AssociationElement>();
                        foreach (Expression index in part.getIndices())
                            result.Add(new AssociationElement(index));
                        break;
                }
            }
            return result;
        }
    }
}