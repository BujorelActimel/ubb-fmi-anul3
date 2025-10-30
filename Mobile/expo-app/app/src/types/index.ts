export interface Transaction {
  id: string;
  accountId: string;
  amount: number;
  currency: string;
  description: string;
  type: 'credit' | 'debit';
  status: 'booked' | 'pending';
  date: string;
  source: 'revolut' | 'custom';
  synced: boolean;
}

export interface PaginationInfo {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasMore: boolean;
}

export interface TransactionsResponse {
  transactions: Transaction[];
  pagination: PaginationInfo;
}

export interface AuthResponse {
  token: string;
  userId: string;
  accounts: Account[];
}

export interface Account {
  AccountId: string;
  Currency: string;
  Nickname: string;
}

export interface CreateTransactionRequest {
  accountId: string;
  amount: number;
  currency: string;
  description: string;
  type: 'credit' | 'debit';
  status?: 'booked' | 'pending';
  date?: string;
}

export interface WebSocketMessage {
  type: 'transaction_created' | 'transaction_deleted';
  payload: Transaction | { id: string };
}
