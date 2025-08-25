import React, { useState, useRef } from 'react';

const MONTHS = [
	'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
	'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
];

function getDaysInMonth(year, month) {
	return new Date(year, month + 1, 0).getDate();
}

function getFirstDayOfWeek(year, month) {
	return new Date(year, month, 1).getDay();
}


const CalendarCard = ({ onDateSelect, initialDate }) => {
	const today = new Date();
	const [selectedDate, setSelectedDate] = useState(initialDate || today);
	const [month, setMonth] = useState((initialDate || today).getMonth());
	const [year, setYear] = useState((initialDate || today).getFullYear());
			const [showMonthYearPicker, setShowMonthYearPicker] = useState(false);
			const pickerRef = useRef(null);

	const daysInMonth = getDaysInMonth(year, month);
	const firstDay = getFirstDayOfWeek(year, month);
	const years = Array.from({length: 21}, (_, i) => today.getFullYear() - 10 + i);

			React.useEffect(() => {
				function handleClickOutside(event) {
					if (pickerRef.current && !pickerRef.current.contains(event.target)) {
						setShowMonthYearPicker(false);
					}
				}
				if (showMonthYearPicker) {
					document.addEventListener('mousedown', handleClickOutside);
				} else {
					document.removeEventListener('mousedown', handleClickOutside);
				}
				return () => document.removeEventListener('mousedown', handleClickOutside);
			}, [showMonthYearPicker]);

	const handleDateClick = (day) => {
		const newDate = new Date(year, month, day);
		setSelectedDate(newDate);
		if (onDateSelect) onDateSelect(newDate);
	};

	const handlePrevMonth = () => {
		if (month === 0) {
			setMonth(11);
			setYear(y => y - 1);
		} else {
			setMonth(m => m - 1);
		}
	};
	const handleNextMonth = () => {
		if (month === 11) {
			setMonth(0);
			setYear(y => y + 1);
		} else {
			setMonth(m => m + 1);
		}
	};

		return (
			<div className="bg-white rounded-xl shadow p-4 w-full max-w-xs mx-auto">
						<div className="flex items-center justify-between mb-3 select-none relative">
							<button
								aria-label="Bulan sebelumnya"
								onClick={handlePrevMonth}
								className="p-2 rounded-full hover:bg-gray-100 focus:bg-gray-200 transition"
							>
								<svg className="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" /></svg>
							</button>
							<button
								className="text-base font-semibold px-2 py-1 rounded hover:bg-gray-100 focus:bg-gray-200 transition flex items-center gap-1"
								onClick={() => setShowMonthYearPicker(v => !v)}
							>
								<span>{MONTHS[month]}</span>
								<span>{year}</span>
								<svg className="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" /></svg>
							</button>
							<button
								aria-label="Bulan berikutnya"
								onClick={handleNextMonth}
								className="p-2 rounded-full hover:bg-gray-100 focus:bg-gray-200 transition"
							>
								<svg className="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" /></svg>
							</button>
							{showMonthYearPicker && (
								<div ref={pickerRef} className="absolute left-1/2 -translate-x-1/2 top-full mt-2 z-20 bg-white rounded-lg shadow-lg p-3 w-64 border flex flex-col gap-2">
									<div className="flex flex-wrap gap-1 justify-center mb-2">
										{MONTHS.map((m, idx) => (
											<button
												key={m}
												className={`px-2 py-1 rounded text-xs ${idx === month ? 'bg-red-600 text-white' : 'hover:bg-gray-100 text-gray-700'}`}
												onClick={() => { setMonth(idx); }}
											>
												{m.slice(0,3)}
											</button>
										))}
									</div>
									<div className="flex flex-wrap gap-1 justify-center max-h-24 overflow-y-auto">
										{years.map(y => (
											<button
												key={y}
												className={`px-2 py-1 rounded text-xs ${y === year ? 'bg-red-600 text-white' : 'hover:bg-gray-100 text-gray-700'}`}
												onClick={() => { setYear(y); }}
											>
												{y}
											</button>
										))}
									</div>
									<button className="mt-2 text-xs text-gray-500 hover:underline self-center" onClick={() => setShowMonthYearPicker(false)}>Tutup</button>
								</div>
							)}
						</div>
			<div className="grid grid-cols-7 gap-1 text-center text-xs font-semibold text-gray-400 mb-1">
				{['Min','Sen','Sel','Rab','Kam','Jum','Sab'].map(d => <div key={d}>{d}</div>)}
			</div>
			<div className="grid grid-cols-7 gap-1 text-center">
				{Array(firstDay === 0 ? 6 : firstDay - 1).fill(null).map((_, i) => <div key={i}></div>)}
				{Array.from({length: daysInMonth}, (_, i) => {
					const day = i + 1;
					const isSelected = selectedDate.getDate() === day && selectedDate.getMonth() === month && selectedDate.getFullYear() === year;
					return (
						<button
							key={day}
							className={`rounded-full w-8 h-8 flex items-center justify-center transition-colors text-sm font-medium ${isSelected ? 'bg-red-600 text-white shadow' : 'hover:bg-red-100 text-gray-700'}`}
							onClick={() => handleDateClick(day)}
						>
							{day}
						</button>
					);
				})}
			</div>
		</div>
	);
};

export default CalendarCard;
