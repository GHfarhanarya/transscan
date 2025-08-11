const bcrypt = require('bcrypt');
const mysql = require('mysql2/promise');

async function updatePasswords() {
  // Data users dengan tanggal lahir
  const users = [
    { employee_id: 'EMP001', birth_date: '1990-05-20' },
    { employee_id: 'EMP002', birth_date: '1985-09-12' },
    { employee_id: 'EMP003', birth_date: '1993-03-28' }
  ];

  // Koneksi database
  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'transscan'
  });

  for (const user of users) {
    // Hash password berdasarkan tanggal lahir
    const hashedPassword = await bcrypt.hash(user.birth_date, 10);
    
    // Update database
    await connection.execute(
      'UPDATE users SET password = ? WHERE employee_id = ?',
      [hashedPassword, user.employee_id]
    );
    
    console.log(`Updated ${user.employee_id} with password: ${user.birth_date}`);
    console.log(`Hash: ${hashedPassword}`);
  }

  await connection.end();
  console.log('All passwords updated!');
}

updatePasswords().catch(console.error);
