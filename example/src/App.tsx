import { Text, View, StyleSheet, Button } from 'react-native';
import {
  RNMendixEncryptedStorage,
  NativeReloadHandler,
  NativeCookie,
  MxConfiguration,
} from 'mendix-native';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>
        Running on:{' '}
        <Text style={styles.text}>
          {(global as any).nativeFabricUIManager
            ? 'New Architecture'
            : 'Legacy Architecture'}
        </Text>
      </Text>
      <Text>
        Encryption status:{' '}
        <Text style={styles.text}>
          {RNMendixEncryptedStorage.IS_ENCRYPTED
            ? 'Encrypted'
            : 'Not Encrypted'}
        </Text>
      </Text>
      <Button title="Exit App" onPress={() => NativeReloadHandler.exitApp()} />
      <Button title="Reload App" onPress={() => NativeReloadHandler.reload()} />
      <Button title="Clear Cookies" onPress={() => NativeCookie.clearAll()} />
      <Button
        title="Get Constants"
        onPress={() => {
          console.log('MxConfiguration Event:', MxConfiguration);
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    fontWeight: 'bold',
  },
});
