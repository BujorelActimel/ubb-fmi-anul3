import axios, { AxiosInstance } from 'axios';
import {
  Transaction,
  TransactionsResponse,
  AuthResponse,
  CreateTransactionRequest,
} from '../types';
import {
  getAuthToken,
  saveAuthToken,
  removeAuthToken,
  saveTransactions,
  getTransactions,
  saveUnsyncedTransaction,
  getUnsyncedTransactions,
  removeUnsyncedTransaction,
} from './storage';

// Configure your server URL here
const API_BASE_URL = 'http://localhost:8080';

class APIService {
  private client: AxiosInstance;
  private isOnline: boolean = true;

  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Add auth token to requests
    this.client.interceptors.request.use(async (config) => {
      const token = await getAuthToken();
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });
  }

  setOnlineStatus(online: boolean) {
    this.isOnline = online;
  }

  // Auth methods
  async initiateLogin(): Promise<{ authUrl: string; state: string }> {
    const response = await this.client.get('/auth/login');
    return response.data;
  }

  async handleCallback(code: string, state: string): Promise<AuthResponse> {
    const response = await this.client.get(`/auth/callback?code=${code}&state=${state}`);
    await saveAuthToken(response.data.token);
    return response.data;
  }

  async logout(): Promise<void> {
    try {
      await this.client.post('/auth/logout');
    } finally {
      await removeAuthToken();
    }
  }

  // Transactions methods
  async getTransactions(
    page: number = 1,
    limit: number = 20,
    search?: string
  ): Promise<TransactionsResponse> {
    if (!this.isOnline) {
      // Return cached transactions when offline
      const cached = await getTransactions();
      const filtered = search
        ? cached.filter(tx => tx.description.toLowerCase().includes(search.toLowerCase()))
        : cached;

      const start = (page - 1) * limit;
      const end = start + limit;
      const paginated = filtered.slice(start, end);

      return {
        transactions: paginated,
        pagination: {
          page,
          limit,
          total: filtered.length,
          totalPages: Math.ceil(filtered.length / limit),
          hasMore: end < filtered.length,
        },
      };
    }

    try {
      const params: any = { page, limit };
      if (search) params.search = search;

      const response = await this.client.get<TransactionsResponse>('/api/transactions', { params });

      // Cache transactions
      if (page === 1) {
        await saveTransactions(response.data.transactions);
      }

      return response.data;
    } catch (error) {
      console.error('Failed to fetch transactions:', error);
      // Fallback to cached data
      return this.getTransactions(page, limit, search);
    }
  }

  async createTransaction(transaction: CreateTransactionRequest): Promise<Transaction> {
    if (!this.isOnline) {
      // Store offline and mark as unsynced
      const offlineTransaction: Transaction = {
        id: `temp-${Date.now()}`,
        ...transaction,
        date: transaction.date || new Date().toISOString(),
        status: transaction.status || 'pending',
        source: 'custom',
        synced: false,
      };

      await saveUnsyncedTransaction(offlineTransaction);
      return offlineTransaction;
    }

    try {
      const response = await this.client.post<{ transaction: Transaction }>(
        '/api/transactions',
        transaction
      );
      return response.data.transaction;
    } catch (error) {
      console.error('Failed to create transaction:', error);
      // Fall back to offline mode
      this.isOnline = false;
      return this.createTransaction(transaction);
    }
  }

  async deleteTransaction(id: string): Promise<void> {
    await this.client.delete(`/api/transactions/${id}`);
  }

  // Sync unsynced transactions
  async syncUnsyncedTransactions(): Promise<number> {
    const unsynced = await getUnsyncedTransactions();
    let syncedCount = 0;

    for (const transaction of unsynced) {
      try {
        const { id, synced, source, ...transactionData } = transaction;
        await this.createTransaction(transactionData);
        await removeUnsyncedTransaction(id);
        syncedCount++;
      } catch (error) {
        console.error(`Failed to sync transaction ${transaction.id}:`, error);
      }
    }

    return syncedCount;
  }
}

export const apiService = new APIService();
