// const bcrypt = require('bcrypt');
// const mysql = require('mysql2/promise');

// async function createNewUsers() {
//   // Data users baru dengan tanggal lahir
//   const users = [
//     { 
//       employee_id: 'EMP004', 
//       name: 'John Doe', 
//       role: 'staff', 
//       birth_date: '1992-06-15',
//       password: '15061992' // DDMMYYYY
//     },
//     { 
//       employee_id: 'EMP005', 
//       name: 'Jane Smith', 
//       role: 'admin', 
//       birth_date: '1988-11-22',
//       password: '22111988' // DDMMYYYY
//     },
//     { 
//       employee_id: 'EMP006', 
//       name: 'Ahmad Rizki', 
//       role: 'staff', 
//       birth_date: '1995-03-08',
//       password: '08031995' // DDMMYYYY
//     }
//   ];

//   try {
//     // Koneksi database
//     const connection = await mysql.createConnection({
//       host: 'localhost',
//       user: 'root',
//       password: '',
//       database: 'transscan'
//     });

//     console.log('Connected to database...');

//     for (const user of users) {
//       // Hash password berdasarkan tanggal lahir format DDMMYYYY
//       const hashedPassword = await bcrypt.hash(user.password, 10);
      
//       // Insert user baru ke database
//       await connection.execute(
//         'INSERT INTO users (employee_id, name, role, birth_date, password) VALUES (?, ?, ?, ?, ?)',
//         [user.employee_id, user.name, user.role, user.birth_date, hashedPassword]
//       );
      
//       console.log(`Created user: ${user.employee_id} - ${user.name}`);
//       console.log(`Password: ${user.password} (from birth_date: ${user.birth_date})`);
//       console.log(`Role: ${user.role}`);
//       console.log('---');
//     }

//     await connection.end();
//     console.log('All users created successfully!');
    
//   } catch (error) {
//     console.error('Error:', error.message);
//   }
// }

// createNewUsers();
