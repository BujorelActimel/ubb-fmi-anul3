import { getAuthToken } from './storage';
import { WebSocketMessage, Transaction } from '../types';

class WebSocketService {
  private ws: WebSocket | null = null;
  private listeners: Set<(message: WebSocketMessage) => void> = new Set();
  private reconnectTimeout: NodeJS.Timeout | null = null;
  private shouldReconnect: boolean = true;

  async connect() {
    const token = await getAuthToken();
    if (!token) {
      console.log('No auth token, skipping WebSocket connection');
      return;
    }

    try {
      // Note: In React Native, use the ws:// protocol
      this.ws = new WebSocket(`ws://localhost:8080/ws?token=${token}`);

      this.ws.onopen = () => {
        console.log('WebSocket connected');
        if (this.reconnectTimeout) {
          clearTimeout(this.reconnectTimeout);
          this.reconnectTimeout = null;
        }
      };

      this.ws.onmessage = (event) => {
        try {
          const message: WebSocketMessage = JSON.parse(event.data);
          this.listeners.forEach(listener => listener(message));
        } catch (error) {
          console.error('Failed to parse WebSocket message:', error);
        }
      };

      this.ws.onerror = (error) => {
        console.error('WebSocket error:', error);
      };

      this.ws.onclose = () => {
        console.log('WebSocket disconnected');
        this.ws = null;

        // Attempt to reconnect after 5 seconds if should reconnect
        if (this.shouldReconnect) {
          this.reconnectTimeout = setTimeout(() => {
            console.log('Attempting to reconnect WebSocket...');
            this.connect();
          }, 5000);
        }
      };
    } catch (error) {
      console.error('Failed to connect WebSocket:', error);
    }
  }

  disconnect() {
    this.shouldReconnect = false;
    if (this.reconnectTimeout) {
      clearTimeout(this.reconnectTimeout);
      this.reconnectTimeout = null;
    }
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }

  addListener(listener: (message: WebSocketMessage) => void) {
    this.listeners.add(listener);
  }

  removeListener(listener: (message: WebSocketMessage) => void) {
    this.listeners.delete(listener);
  }

  isConnected(): boolean {
    return this.ws !== null && this.ws.readyState === WebSocket.OPEN;
  }
}

export const wsService = new WebSocketService();
