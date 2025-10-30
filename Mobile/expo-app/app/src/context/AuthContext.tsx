import React, { createContext, useState, useEffect, useContext } from 'react';
import { getAuthToken, getUserID, saveUserID, clearAllData } from '../services/storage';
import { apiService } from '../services/api';
import { wsService } from '../services/websocket';

interface AuthContextType {
  isAuthenticated: boolean;
  userID: string | null;
  login: (code: string, state: string) => Promise<void>;
  logout: () => Promise<void>;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [userID, setUserID] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  useEffect(() => {
    if (isAuthenticated) {
      wsService.connect();
    } else {
      wsService.disconnect();
    }
  }, [isAuthenticated]);

  const checkAuth = async () => {
    try {
      const token = await getAuthToken();
      const savedUserID = await getUserID();
      setIsAuthenticated(!!token);
      setUserID(savedUserID);
    } catch (error) {
      console.error('Failed to check auth:', error);
    } finally {
      setLoading(false);
    }
  };

  const login = async (code: string, state: string) => {
    try {
      const response = await apiService.handleCallback(code, state);
      await saveUserID(response.userId);
      setUserID(response.userId);
      setIsAuthenticated(true);
    } catch (error) {
      console.error('Login failed:', error);
      throw error;
    }
  };

  const logout = async () => {
    try {
      await apiService.logout();
    } catch (error) {
      console.error('Logout failed:', error);
    } finally {
      await clearAllData();
      setIsAuthenticated(false);
      setUserID(null);
    }
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, userID, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
