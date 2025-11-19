import { StyleSheet, Text, View, TouchableOpacity } from 'react-native';
import { storage } from '../storage';

export default function HomeScreen({ navigation }: any) {
  const handleLogout = async () => {
    await storage.removeToken();
    navigation.replace('Auth');
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Trail Logger</Text>
      <Text style={styles.subtitle}>Home Screen</Text>
      <Text style={styles.text}>You are logged in!</Text>

      <TouchableOpacity style={styles.button} onPress={handleLogout}>
        <Text style={styles.buttonText}>Logout</Text>
      </TouchableOpacity>
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
    fontSize: 16,
    marginBottom: 16,
  },
  text: {
    color: '#ebdbb2',
    fontSize: 14,
    marginBottom: 32,
  },
  button: {
    backgroundColor: '#fb4934',
    paddingVertical: 14,
    paddingHorizontal: 32,
    borderRadius: 8,
  },
  buttonText: {
    color: '#282828',
    fontSize: 16,
    fontWeight: '700',
  },
});
