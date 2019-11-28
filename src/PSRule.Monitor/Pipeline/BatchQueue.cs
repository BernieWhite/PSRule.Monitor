﻿// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Monitor.Data;
using System.Collections.Concurrent;
using System.Collections.Generic;

namespace PSRule.Monitor.Pipeline
{
    internal sealed class BatchQueue
    {
        private readonly ConcurrentQueue<LogRecord> _Queue;

        public BatchQueue()
        {
            _Queue = new ConcurrentQueue<LogRecord>();
        }

        public int Count
        {
            get { return _Queue.Count; }
        }

        public bool IsEmpty
        {
            get { return _Queue.IsEmpty; }
        }

        public void Enqueue(LogRecord record)
        {
            if (record == null)
                return;

            _Queue.Enqueue(record);
        }

        public bool TryDequeue(int minSize, int maxSize, out LogRecord[] records)
        {
            records = null;
            if (_Queue.Count < minSize || _Queue.Count == 0)
                return false;

            var batchSize = _Queue.Count > maxSize ? maxSize : _Queue.Count;
            var batch = new List<LogRecord>(batchSize);
            for (var i = 0; i < maxSize && _Queue.Count > 0; i++)
            {
                if (_Queue.TryDequeue(out LogRecord record))
                    batch.Add(record);
            }
            records = batch.ToArray();
            return true;
        }
    }
}
