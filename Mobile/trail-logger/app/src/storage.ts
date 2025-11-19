import AsyncStorage from '@react-native-async-storage/async-storage';

export const storage = {
  saveToken: async (token: string) => {
    await AsyncStorage.setItem('token', token);
  },

  getToken: async () => {
    return await AsyncStorage.getItem('token');
  },

  removeToken: async () => {
    await AsyncStorage.removeItem('token');
  },

  savePhotos: async (photos: { [key: number]: string[] }) => {
    await AsyncStorage.setItem('trail_photos', JSON.stringify(photos));
  },

  getPhotos: async (): Promise<{ [key: number]: string[] }> => {
    const data = await AsyncStorage.getItem('trail_photos');
    return data ? JSON.parse(data) : {};
  },

  savePendingTrails: async (trails: any[]) => {
    await AsyncStorage.setItem('pending_trails', JSON.stringify(trails));
  },

  getPendingTrails: async (): Promise<any[]> => {
    const data = await AsyncStorage.getItem('pending_trails');
    return data ? JSON.parse(data) : [];
  },

  addPendingTrail: async (trail: any) => {
    const pending = await storage.getPendingTrails();
    pending.push({ ...trail, tempId: Date.now(), timestamp: new Date().toISOString() });
    await storage.savePendingTrails(pending);
  },

  removePendingTrail: async (tempId: number) => {
    const pending = await storage.getPendingTrails();
    const filtered = pending.filter((t: any) => t.tempId !== tempId);
    await storage.savePendingTrails(filtered);
  },

  saveTrailsCache: async (trails: any[]) => {
    await AsyncStorage.setItem('trails_cache', JSON.stringify(trails));
  },

  getTrailsCache: async (): Promise<any[]> => {
    const data = await AsyncStorage.getItem('trails_cache');
    return data ? JSON.parse(data) : [];
  },

  savePendingPhotos: async (photos: any[]) => {
    await AsyncStorage.setItem('pending_photos', JSON.stringify(photos));
  },

  getPendingPhotos: async (): Promise<any[]> => {
    const data = await AsyncStorage.getItem('pending_photos');
    return data ? JSON.parse(data) : [];
  },

  addPendingPhoto: async (trailId: number, photoUri: string) => {
    const pending = await storage.getPendingPhotos();
    pending.push({ trailId, photoUri, tempId: Date.now() });
    await storage.savePendingPhotos(pending);
  },

  removePendingPhoto: async (tempId: number) => {
    const pending = await storage.getPendingPhotos();
    const filtered = pending.filter((p: any) => p.tempId !== tempId);
    await storage.savePendingPhotos(filtered);
  },
};
