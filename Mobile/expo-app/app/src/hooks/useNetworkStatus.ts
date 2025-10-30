import { useEffect, useState } from 'react';
import NetInfo from '@react-native-community/netinfo';
import { apiService } from '../services/api';

export const useNetworkStatus = () => {
  const [isOnline, setIsOnline] = useState(true);

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener(state => {
      const online = state.isConnected ?? false;
      setIsOnline(online);
      apiService.setOnlineStatus(online);

      // Sync unsynced transactions when coming back online
      if (online) {
        apiService.syncUnsyncedTransactions().then(count => {
          if (count > 0) {
            console.log(`Synced ${count} transactions`);
          }
        });
      }
    });

    return () => unsubscribe();
  }, []);

  return isOnline;
};
