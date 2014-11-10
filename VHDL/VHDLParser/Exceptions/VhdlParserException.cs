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
namespace VHDL.parser
{
    /// <summary>
    /// Vhdl parser exception.
    /// </summary>
    public class VhdlParserException : Exception
    {
        /// <summary>
        /// Creates a new instance of <code>VhdlParserException</code> without detail message.
        /// </summary>
        public VhdlParserException()
        {
        }

        /// <summary>
        /// Constructs an instance of <code>VhdlParserException</code> with the specified detail message.
        /// </summary>
        /// <param name="msg">the detail message.</param>
        public VhdlParserException(string msg)
            : base(msg)
        {
        }
    }
}