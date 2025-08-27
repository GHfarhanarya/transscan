import React, { useEffect, useState } from 'react';

const API_URL = 'http://35.219.66.90';

const ActivityLogCard = () => {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchLogs = async () => {
      setLoading(true);
      setError(null);
      try {
        const token = localStorage.getItem('jwtToken');
        const res = await fetch(`${API_URL}/activity-logs`, {
          headers: {
            'Authorization': token
          }
        });
        if (!res.ok) throw new Error('Gagal mengambil data log aktivitas');
        const data = await res.json();
        setLogs(data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    fetchLogs();
  }, []);

  return (
    <div className="bg-white rounded-lg shadow-md p-4 w-full md:w-1/2">
      <h2 className="text-lg font-semibold mb-4">Log Aktivitas Admin</h2>
      {loading ? (
        <div className="text-gray-500">Loading...</div>
      ) : error ? (
        <div className="text-red-500">{error}</div>
      ) : logs.length === 0 ? (
        <div className="text-gray-500">Belum ada aktivitas.</div>
      ) : (
        <ul className="divide-y divide-gray-200">
          {logs.map((log) => (
            <li key={log.id} className="py-2 flex flex-col md:flex-row md:items-center md:justify-between">
              <div>
                <span className="font-medium">{log.User?.name || log.userId}</span> - <span className="text-blue-600">{log.action}</span>
                <div className="text-sm text-gray-500">{log.details}</div>
              </div>
              <div className="text-xs text-gray-400 md:text-right mt-1 md:mt-0">{new Date(log.timestamp).toLocaleString()}</div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default ActivityLogCard;
