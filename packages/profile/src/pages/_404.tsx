import React from 'react';
import { View, Text } from 'react-native';

export default function NotFound() {
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Text style={{ fontSize: 18, fontWeight: 'bold' }}>Page Not Found</Text>
      <Text style={{ marginTop: 10 }}>The page you are looking for does not exist.</Text>
    </View>
  );
}