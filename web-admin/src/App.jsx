import { BrowserRouter, Routes, Route } from 'react-router-dom';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import ProtectedRoute from './components/ProtectedRoute';

function App() {
  return (
    <BrowserRouter>
      <Routes>
          {/* login */}
        <Route path="/login" element={<LoginPage />} />

        {/* dashboard */}
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <DashboardPage/>
            </ProtectedRoute>
          }
        />

        <Route path="*" element={<LoginPage />}/>
      </Routes>
    </BrowserRouter>
  );
}

export default App;