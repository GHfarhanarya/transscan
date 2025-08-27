
import React, { useEffect, useState } from 'react';
import dayjs from 'dayjs';
import { ClockIcon, CalendarIcon } from '../components/DateTimeIcons';

const RealtimeDateTime = () => {
  const [now, setNow] = useState(dayjs());

  useEffect(() => {
    const interval = setInterval(() => {
      setNow(dayjs());
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="bg-white/80 rounded-xl shadow flex flex-col sm:flex-row items-center gap-2 px-4 py-3 border border-gray-200 w-fit">
      <div className="flex items-center gap-2">
        <CalendarIcon className="w-6 h-6 text-red-500" />
        <span className="font-semibold text-lg text-gray-800">
          {now.format('dddd, DD MMMM YYYY')}
        </span>
      </div>
      <div className="hidden sm:block w-px h-6 bg-gray-200 mx-3" />
      <div className="flex items-center gap-2">
        <ClockIcon className="w-6 h-6 text-red-500" />
        <span className="font-mono text-lg text-red-700 tracking-widest">
          {now.format('HH:mm:ss')}
        </span>
      </div>
    </div>
  );
};

export default RealtimeDateTime;
