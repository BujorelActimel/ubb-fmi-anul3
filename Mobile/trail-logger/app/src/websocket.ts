import { storage } from './storage';
import config from '../config.json';

const WS_URL = config.serverUrl.replace('https://', 'wss://').replace('http://', 'ws://') + '/ws';

class WebSocketService {
  private ws: WebSocket | null = null;
  private reconnectTimeout: any = null;
  private listeners: ((message: any) => void)[] = [];
  private shouldConnect: boolean = true;

  connect = async () => {
    try {
      const token = await storage.getToken();
      if (!token || !this.shouldConnect) return;

      this.ws = new WebSocket(`${WS_URL}?token=${token}`);

      this.ws.onopen = () => {
        console.log('WebSocket connected');
      };

      this.ws.onmessage = (event) => {
        try {
          const message = JSON.parse(event.data);
          console.log('WebSocket message:', message);
          this.listeners.forEach(listener => listener(message));
        } catch (error) {
          console.error('Error parsing WebSocket message:', error);
        }
      };

      this.ws.onerror = () => {
        // Silently handle errors - don't show to user
      };

      this.ws.onclose = () => {
        console.log('WebSocket disconnected');
        // Only reconnect if we should be connected
        if (this.shouldConnect) {
          this.reconnectTimeout = setTimeout(() => {
            this.connect();
          }, 5000);
        }
      };
    } catch (error) {
      // Silently handle connection errors
    }
  };

  disconnect = () => {
    this.shouldConnect = false;
    if (this.reconnectTimeout) {
      clearTimeout(this.reconnectTimeout);
    }
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  };

  addListener = (callback: (message: any) => void) => {
    this.listeners.push(callback);
  };

  removeListener = (callback: (message: any) => void) => {
    this.listeners = this.listeners.filter(listener => listener !== callback);
  };
}

export const wsService = new WebSocketService();
