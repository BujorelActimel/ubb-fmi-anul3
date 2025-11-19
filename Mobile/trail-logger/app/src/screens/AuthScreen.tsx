import { useState } from 'react';
import { StyleSheet, Text, View, TextInput, TouchableOpacity, Alert } from 'react-native';
import { api } from '../api';
import { storage } from '../storage';

export default function AuthScreen({ navigation }: any) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [username, setUsername] = useState('');
  const [loading, setLoading] = useState(false);
  const [isRegisterMode, setIsRegisterMode] = useState(false);

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      const result = await api.login(email, password);
      await storage.saveToken(result.token);
      navigation.replace('Home');
    } catch (error: any) {
      Alert.alert('Login Failed', error.response?.data?.error || 'Please try again');
    } finally {
      setLoading(false);
    }
  };

  const handleRegister = async () => {
    if (!email || !password || !username) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      const result = await api.register(username, email, password);
      await storage.saveToken(result.token);
      navigation.replace('Home');
    } catch (error: any) {
      Alert.alert('Registration Failed', error.response?.data?.error || 'Please try again');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Trail Logger</Text>
      <Text style={styles.subtitle}>
        {isRegisterMode ? 'Create your account' : 'Sign in to continue'}
      </Text>

      <View style={styles.form}>
        {isRegisterMode && (
          <TextInput
            style={styles.input}
            placeholder="Username"
            placeholderTextColor="#928374"
            value={username}
            onChangeText={setUsername}
            autoCapitalize="none"
          />
        )}

        <TextInput
          style={styles.input}
          placeholder="Email"
          placeholderTextColor="#928374"
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
        />

        <TextInput
          style={styles.input}
          placeholder="Password"
          placeholderTextColor="#928374"
          value={password}
          onChangeText={setPassword}
          secureTextEntry
        />

        <TouchableOpacity
          style={styles.button}
          onPress={isRegisterMode ? handleRegister : handleLogin}
        >
          <Text style={styles.buttonText}>
            {loading
              ? (isRegisterMode ? 'Creating account...' : 'Signing in...')
              : (isRegisterMode ? 'Sign Up' : 'Sign In')
            }
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.linkButton}
          onPress={() => setIsRegisterMode(!isRegisterMode)}
        >
          <Text style={styles.linkText}>
            {isRegisterMode
              ? 'Already have an account? Sign In'
              : "Don't have an account? Sign Up"}
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#282828',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  title: {
    color: '#fbf1c7',
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 8,
  },
  subtitle: {
    color: '#d5c4a1',
    fontSize: 14,
    marginBottom: 32,
  },
  form: {
    width: '100%',
    maxWidth: 400,
  },
  input: {
    backgroundColor: '#3c3836',
    borderWidth: 1,
    borderColor: '#504945',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 12,
    color: '#fbf1c7',
    fontSize: 16,
    marginBottom: 16,
  },
  button: {
    backgroundColor: '#8ec07c',
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 8,
  },
  buttonText: {
    color: '#282828',
    fontSize: 16,
    fontWeight: '700',
  },
  linkButton: {
    marginTop: 16,
    alignItems: 'center',
  },
  linkText: {
    color: '#8ec07c',
    fontSize: 14,
  },
});
