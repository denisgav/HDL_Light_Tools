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
using System.Text;
using System.IO;
using VHDLRuntime.MySortedDictionary;
using VHDLRuntime.Values;
using VHDLRuntime.ValueDump;
using VHDLRuntime.Objects;
using VHDLRuntime;

namespace VHDLInputGenerators
{
    public enum GeneratorType
    {
        Constant,
        Clock,
        Counter,
        DiscretteRandom,
        ContinousRandom
    }

    public abstract class BaseGenerator
    {
        /// <summary>
        /// Временной шаг
        /// </summary>
        protected TimeInterval timeStep;
        public TimeInterval TimeStep
        {
            get { return timeStep; }
            set { timeStep = value; }
        }

        /// <summary>
        /// Количество сгенерированных значений
        /// </summary>
        protected int valuesCount;
        public int ValuesCount
        {
            get { return valuesCount; }
        }

        /// <summary>
        /// Размер в битах сгенерированного значения
        /// </summary>
        public virtual int SizeInBits
        {
            get { return 1; }
        }

        public BaseGenerator()
        {
            timeStep = new TimeInterval(1, TimeUnit.fs);
        }

        private static SortedList<UInt64, TimeStampInfo<VHDLBaseValue>> FormIntegerGeneratedData(BaseGenerator generator, UInt64 StartTime, UInt64 EndTime)
        {
            SortedList<UInt64, TimeStampInfo<VHDLBaseValue>> res = new SortedList<UInt64, TimeStampInfo<VHDLBaseValue>>();

            if (generator is IGeneratorDataFill<Int64>)
            {
                SortedList<UInt64, Int64> valuesForInsert = (generator as IGeneratorDataFill<Int64>).InsertValues(StartTime, EndTime);
                foreach (var el in valuesForInsert)
                {
                    TimeStampInfo<VHDLBaseValue> inf = new TimeStampInfo<VHDLBaseValue>(new VHDLIntegerValue(Convert.ToInt32(el.Value)));
                    res.Add(el.Key, inf);
                }
                return res;
            }
            if (generator is IGeneratorDataFill<bool[]>)
            {
                SortedList<UInt64, bool[]> valuesForInsert = (generator as IGeneratorDataFill<bool[]>).InsertValues(StartTime, EndTime);
                foreach (var el in valuesForInsert)
                {
                    TimeStampInfo<VHDLBaseValue> inf = new TimeStampInfo<VHDLBaseValue>(new VHDLIntegerValue(DataConvertorUtils.ToInt(el.Value)));
                    res.Add(el.Key, inf);
                }
                return res;
            }
            if (generator is IGeneratorDataFill<Double>)
            {
                SortedList<UInt64, Double> valuesForInsert = (generator as IGeneratorDataFill<Double>).InsertValues(StartTime, EndTime);
                foreach (var el in valuesForInsert)
                {
                    TimeStampInfo<VHDLBaseValue> inf = new TimeStampInfo<VHDLBaseValue>(new VHDLIntegerValue(Convert.ToInt32(el.Value)));
                    res.Add(el.Key, inf);
                }
                return res;
            }

            return res;
        }

        private static SortedList<UInt64, TimeStampInfo<VHDLBaseValue>> FormRealGeneratedData(BaseGenerator generator, UInt64 StartTime, UInt64 EndTime)
        {
            SortedList<UInt64, TimeStampInfo<VHDLBaseValue>> res = new SortedList<UInt64, TimeStampInfo<VHDLBaseValue>>();

            if (generator is IGeneratorDataFill<Int64>)
            {
                SortedList<UInt64, Int64> valuesForInsert = (generator as IGeneratorDataFill<Int64>).InsertValues(StartTime, EndTime);
                foreach (var el in valuesForInsert)
                {
                    TimeStampInfo<VHDLBaseValue> inf = new TimeStampInfo<VHDLBaseValue>(new VHDLFloatingPointValue(Convert.ToDouble(el.Value)));
                    res.Add(el.Key, inf);
                }
                return res;
            }
            if (generator is IGeneratorDataFill<bool[]>)
            {
                SortedList<UInt64, bool[]> valuesForInsert = (generator as IGeneratorDataFill<bool[]>).InsertValues(StartTime, EndTime);
                foreach (var el in valuesForInsert)
                {
                    TimeStampInfo<VHDLBaseValue> inf = new TimeStampInfo<VHDLBaseValue>(new VHDLFloatingPointValue(DataConvertorUtils.ToInt(el.Value)));
                    res.Add(el.Key, inf);
                }
                return res;
            }
            if (generator is IGeneratorDataFill<Double>)
            {
                SortedList<UInt64, Double> valuesForInsert = (generator as IGeneratorDataFill<Double>).InsertValues(StartTime, EndTime);
                foreach (var el in valuesForInsert)
                {
                    TimeStampInfo<VHDLBaseValue> inf = new TimeStampInfo<VHDLBaseValue>(new VHDLFloatingPointValue(Convert.ToDouble(el.Value)));
                    res.Add(el.Key, inf);
                }
                return res;
            }

            return res;
        }




        public static SortedList<UInt64, TimeStampInfo<VHDLBaseValue>> FormGeneratedData(BaseGenerator generator, UInt64 StartTime, UInt64 EndTime)
        {
            SortedList<UInt64, TimeStampInfo<VHDLBaseValue>> res = new SortedList<UInt64, TimeStampInfo<VHDLBaseValue>>();

            return res;
        }

        public void Fill(Signal signal, UInt64 StartTime, UInt64 EndTime)
        {

            int valuesCount = (int)((EndTime - StartTime) / timeStep.GetTimeUnitInFS());
            if (valuesCount > 100000)
            {
                throw new Exception("Can't generate too big number of data.\nTry to select smaller time diapasone or bigger time step");
            }


            SortedList<UInt64, TimeStampInfo<VHDLBaseValue>> newData = FormGeneratedData(this, StartTime, EndTime);
            signal.Dump.InsertValues(newData, StartTime, EndTime);
        }

        public virtual string GetStringStartValue() { throw new Exception(); }
        public virtual StringBuilder StringVhdlRealization(KeyValuePair<String, TimeInterval> param) { throw new Exception(); }
        public virtual void StreamVhdlRealization(KeyValuePair<String, TimeInterval> param, StreamWriter sw) { throw new Exception(); }
        //param.Val - END_TIME
        //step - field
    }
}