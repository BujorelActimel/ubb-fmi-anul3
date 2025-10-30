import AsyncStorage from '@react-native-async-storage/async-storage';
import { Transaction } from '../types';

const STORAGE_KEYS = {
  AUTH_TOKEN: '@auth_token',
  USER_ID: '@user_id',
  TRANSACTIONS: '@transactions',
  UNSYNCED_TRANSACTIONS: '@unsynced_transactions',
};

// Auth token management
export const saveAuthToken = async (token: string): Promise<void> => {
  await AsyncStorage.setItem(STORAGE_KEYS.AUTH_TOKEN, token);
};

export const getAuthToken = async (): Promise<string | null> => {
  return await AsyncStorage.getItem(STORAGE_KEYS.AUTH_TOKEN);
};

export const removeAuthToken = async (): Promise<void> => {
  await AsyncStorage.removeItem(STORAGE_KEYS.AUTH_TOKEN);
};

// User ID management
export const saveUserID = async (userID: string): Promise<void> => {
  await AsyncStorage.setItem(STORAGE_KEYS.USER_ID, userID);
};

export const getUserID = async (): Promise<string | null> => {
  return await AsyncStorage.getItem(STORAGE_KEYS.USER_ID);
};

export const removeUserID = async (): Promise<void> => {
  await AsyncStorage.removeItem(STORAGE_KEYS.USER_ID);
};

// Transactions cache
export const saveTransactions = async (transactions: Transaction[]): Promise<void> => {
  await AsyncStorage.setItem(STORAGE_KEYS.TRANSACTIONS, JSON.stringify(transactions));
};

export const getTransactions = async (): Promise<Transaction[]> => {
  const data = await AsyncStorage.getItem(STORAGE_KEYS.TRANSACTIONS);
  return data ? JSON.parse(data) : [];
};

export const clearTransactions = async (): Promise<void> => {
  await AsyncStorage.removeItem(STORAGE_KEYS.TRANSACTIONS);
};

// Unsynced transactions management
export const saveUnsyncedTransaction = async (transaction: Transaction): Promise<void> => {
  const unsynced = await getUnsyncedTransactions();
  unsynced.push(transaction);
  await AsyncStorage.setItem(STORAGE_KEYS.UNSYNCED_TRANSACTIONS, JSON.stringify(unsynced));
};

export const getUnsyncedTransactions = async (): Promise<Transaction[]> => {
  const data = await AsyncStorage.getItem(STORAGE_KEYS.UNSYNCED_TRANSACTIONS);
  return data ? JSON.parse(data) : [];
};

export const removeUnsyncedTransaction = async (id: string): Promise<void> => {
  const unsynced = await getUnsyncedTransactions();
  const filtered = unsynced.filter(tx => tx.id !== id);
  await AsyncStorage.setItem(STORAGE_KEYS.UNSYNCED_TRANSACTIONS, JSON.stringify(filtered));
};

export const clearUnsyncedTransactions = async (): Promise<void> => {
  await AsyncStorage.removeItem(STORAGE_KEYS.UNSYNCED_TRANSACTIONS);
};

// Clear all data (logout)
export const clearAllData = async (): Promise<void> => {
  await Promise.all([
    removeAuthToken(),
    removeUserID(),
    clearTransactions(),
    clearUnsyncedTransactions(),
  ]);
};
