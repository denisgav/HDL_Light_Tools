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
using Antlr.Runtime;

namespace VHDLParser.antlr
{
    public class AbstractVhdlAntlrParser : Parser
    {
        private List<RecognitionException> errors;
        public List<RecognitionException> Errors
        {
            get
            {
                return errors;
            }
        }

        public AbstractVhdlAntlrParser(ITokenStream input)
            : base(input, new RecognizerSharedState())
        {
            errors = new List<RecognitionException>();
        }

        public AbstractVhdlAntlrParser(ITokenStream input, RecognizerSharedState state)
            : base(input, state)
        {
            errors = new List<RecognitionException>();
        }

        public override void DisplayRecognitionError(string[] tokenNames, RecognitionException e)
        {
            base.DisplayRecognitionError(tokenNames, e);
            errors.Add(e);
        }
    }
}
