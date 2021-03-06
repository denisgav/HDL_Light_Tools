﻿//
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

namespace VHDLCompiler.CodeTemplates.Statements
{
    public partial class RegisterInertialDelayEvent
    {
        private string schedulerName;
        public string SchedulerName
        {
            get { return schedulerName; }
            set { schedulerName = value; }
        }

        private string signalName;
        public string SignalName
        {
            get { return signalName; }
            set { signalName = value; }
        }

        private List<string> events;
        public List<string> Events
        {
            get { return events; }
            set { events = value; }
        }

        private string regection;
        public string Regection
        {
            get { return regection; }
            set { regection = value; }
        }

        public RegisterInertialDelayEvent(string signalName, List<string> events)
            : this(signalName, events, "None")
        { }

        public RegisterInertialDelayEvent(string signalName, List<string> events, string regection)
        {
            this.signalName = signalName;
            this.events = events;
            this.regection = regection;
            schedulerName = "Scheduler";
        }
    }
}
