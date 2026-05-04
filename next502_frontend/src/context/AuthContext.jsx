import React, { createContext, useState, useContext, useEffect } from 'react';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userRole, setUserRole] = useState(null);
  const [userId, setUserId] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('ACCESS_TOKEN');
    const role = localStorage.getItem('USER_ROLE');
    const id = localStorage.getItem('USER_ID');

    if (token) {
      setUser({ token, role, userId: id });
      setUserRole(role);
      setUserId(id);
      setIsLoggedIn(true);
    }
    setLoading(false);
  }, []);

  const loginSuccess = (accessToken, role, id) => {
    localStorage.setItem('ACCESS_TOKEN', accessToken);
    localStorage.setItem('USER_ROLE', role);
    localStorage.setItem('USER_ID', id);
    setUser({ token: accessToken, role, userId: id });
    setUserRole(role);
    setUserId(id);
    setIsLoggedIn(true);
  };

  const logout = () => {
    localStorage.removeItem('ACCESS_TOKEN');
    localStorage.removeItem('REFRESH_TOKEN');
    localStorage.removeItem('USER_ROLE');
    localStorage.removeItem('USER_ID');
    setUser(null);
    setUserRole(null);
    setUserId(null);
    setIsLoggedIn(false);
  };

  return (
    <AuthContext.Provider
      value={{ user, isLoggedIn, userRole, userId, loading, loginSuccess, logout }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
