const bcrypt = require('bcrypt');

async function generatePassword() {
  const password = 'budi123';
  const hash = await bcrypt.hash(password, 10);
  console.log('Password:', password);
  console.log('Hash:', hash);
  
  // Test verify
  const isValid = await bcrypt.compare(password, hash);
  console.log('Verification:', isValid);
  
  // Test with existing hash
  const existingHash = '$2b$10$g1zQoSGOpQMtU6H0byR5qOer6dC0/RH6Sa0FGpVXhUpGfbIm3CVyC';
  const testPassword = 'budi123';
  const isExistingValid = await bcrypt.compare(testPassword, existingHash);
  console.log('Existing hash valid with budi123:', isExistingValid);
  
  // Try other common passwords
  const commonPasswords = ['123456', 'password', 'admin', 'budi', 'santoso'];
  for (const pwd of commonPasswords) {
    const valid = await bcrypt.compare(pwd, existingHash);
    if (valid) {
      console.log(`Found password: ${pwd}`);
    }
  }
}

generatePassword();
