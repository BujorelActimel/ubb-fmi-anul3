import axios from 'axios';
import Constants from 'expo-constants';
import { storage } from './storage';
import config from '../config.json';

const API_URL = Constants.expoConfig?.extra?.apiUrl || config.serverUrl;

const getHeaders = async () => {
  const token = await storage.getToken();
  return {
    Authorization: token ? `Bearer ${token}` : '',
  };
};

export const api = {
  register: async (username: string, email: string, password: string) => {
    const response = await axios.post(`${API_URL}/auth/register`, {
      username,
      email,
      password,
    });
    return response.data;
  },

  login: async (email: string, password: string) => {
    const response = await axios.post(`${API_URL}/auth/login`, {
      email,
      password,
    });
    return response.data;
  },

  getTrails: async (params: any = {}) => {
    const headers = await getHeaders();
    const response = await axios.get(`${API_URL}/api/trails`, { headers, params });
    return response.data;
  },

  createTrail: async (trail: any) => {
    const headers = await getHeaders();
    const response = await axios.post(`${API_URL}/api/trails`, trail, { headers });
    return response.data;
  },

  updateTrail: async (trailId: number, trail: any) => {
    const headers = await getHeaders();
    const response = await axios.put(`${API_URL}/api/trail?id=${trailId}`, trail, { headers });
    return response.data;
  },

  deleteTrail: async (trailId: number) => {
    const headers = await getHeaders();
    const response = await axios.delete(`${API_URL}/api/trail?id=${trailId}`, { headers });
    return response.data;
  },

  uploadPhoto: async (trailId: number, photoUri: string) => {
    const headers = await getHeaders();
    const formData = new FormData();

    // Extract filename from URI
    const filename = photoUri.split('/').pop() || 'photo.jpg';

    formData.append('photo', {
      uri: photoUri,
      type: 'image/jpeg',
      name: filename,
    } as any);

    const response = await axios.post(
      `${API_URL}/api/photos?trail_id=${trailId}`,
      formData,
      {
        headers: {
          ...headers,
          'Content-Type': 'multipart/form-data',
        },
      }
    );
    return response.data;
  },

  getPhotos: async (trailId: number) => {
    const headers = await getHeaders();
    const response = await axios.get(`${API_URL}/api/photos?trail_id=${trailId}`, { headers });
    return response.data;
  },

  getPhotoUrl: (serverUrl: string) => {
    return `${API_URL}${serverUrl}`;
  },
};
