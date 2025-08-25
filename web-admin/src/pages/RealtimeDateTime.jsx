import React, { useEffect, useState } from 'react';
import dayjs from 'dayjs';

const RealtimeDateTime = () => {
  const [now, setNow] = useState(dayjs());

  useEffect(() => {
    const interval = setInterval(() => {
      setNow(dayjs());
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <p className="mt-1 text-md text-gray-600">
      {now.format('dddd, DD MMMM YYYY HH:mm:ss')}
    </p>
  );
};

export default RealtimeDateTime;
