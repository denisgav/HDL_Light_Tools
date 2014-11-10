using System;
using VHDL.parser.antlr;
using System.Collections.Generic;

namespace VHDL
{
    class ObjectSearcher
    {
        private Part.PartList parts;
        private List<object> results = new List<object>();
        private List<IDeclarativeRegion> scopesToSearch = new List<IDeclarativeRegion>();

        public ObjectSearcher(IDeclarativeRegion scope)
        {
            this.scopesToSearch.Add(scope);
        }

        public object search(Part.PartList parts, Predicate<object> pred)
        {
            this.parts = parts;
            this.parts.resetContinuousIterator();

            for (int i = 0; i < scopesToSearch.Count; ++i)
            {
                IDeclarativeRegion scope = scopesToSearch[i];
                foreach (Part part in parts)
                {
                    if (part.Type == Part.TypeEnum.SELECTED)
                    {
                        object obj = scope.Scope.resolve(part.getSuffix());

                        if (pred(obj))
                            return obj;
                        else if (obj is IDeclarativeRegion)
                            if (scopesToSearch[scopesToSearch.Count-1] != obj)
                                scopesToSearch.Add((IDeclarativeRegion)obj);
                        else
                            return null;
                    }
                }
            }

            return null;
        }

        public List<object> searchAll(Part.PartList parts, Predicate<object> pred)
        {
            List<object> result = new List<object>();

            this.parts = parts;
            this.parts.resetContinuousIterator();

            for (int i = 0; i < scopesToSearch.Count; ++i)
            {
                IDeclarativeRegion scope = scopesToSearch[i];
                foreach (Part part in parts)
                {
                    if (part.Type == Part.TypeEnum.SELECTED)
                    {
                        var objects = scope.Scope.resolveAll(part.getSuffix());

                        foreach (object obj in objects)
                        {
                            if (pred(obj))
                                result.Add(obj);
                            else if (obj is IDeclarativeRegion)
                                scopesToSearch.Add((IDeclarativeRegion)obj);
                        }
                    }
                }
            }

            return result;
        }
    }
}
