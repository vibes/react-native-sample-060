/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React from 'react';
import {
  SafeAreaView,
  StyleSheet,
  ScrollView,
  View,
  Text,
  StatusBar,
  NativeEventEmitter,
  NativeModules,
  DeviceEventEmitter,
  TouchableOpacity,
  Button,
  Platform
} from 'react-native';

import {
  Header,
  LearnMoreLinks,
  Colors,
  DebugInstructions,
  ReloadInstructions,
} from 'react-native/Libraries/NewAppScreen';

import Vibes from './Vibes';

const onPushReceived = (event) => {
  alert('Push received. Payload -> ' + event.payload);
};

const onPushOpened = async (event) => {
  if (Platform.OS === 'android') {
    await Vibes.invokeApp();
  }
  alert('Push opened. Payload -> ' + event.payload);
};

const eventEmitter = Platform.OS === 'ios' ? new NativeEventEmitter(NativeModules.PushEventEmitter) : DeviceEventEmitter;

eventEmitter.addListener('pushReceived', onPushReceived);
eventEmitter.addListener('pushOpened', onPushOpened);

const App: () => React$Node = () => {

  const onPressAssociatePerson = async () => {
    try {
      const result = await Vibes.associatePerson('me@vibes.com');
      console.log(result)
    } catch (error) {
      console.error(error);
    }
  };

  const onPressRegisterPush = async () => {
    try {
      const result = await Vibes.registerPush();
      console.log(result)
    } catch (error) {
      console.error(error);
    }

  };

  const onPressUnregisterPush = async () => {
    try {
      const result = await Vibes.unregisterPush();
      console.log(result);
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <>
      <StatusBar barStyle="dark-content" />
      <SafeAreaView>
        <ScrollView
          contentInsetAdjustmentBehavior="automatic"
          style={styles.scrollView}>
          <Header />
          {global.HermesInternal == null ? null : (
            <View style={styles.engine}>
              <Text style={styles.footer}>Engine: Hermes</Text>
            </View>
          )}
          <View style={styles.body}>
            <View style={styles.buttons}>
              <TouchableOpacity style={styles.button}>
                <Button title="Click to associate person"
                  color="#841584"
                  onPress={onPressAssociatePerson}
                />
              </TouchableOpacity>
              <TouchableOpacity style={styles.button}>
                <Button
                  title="Click to register push"
                  color="#E936A7"
                  onPress={onPressRegisterPush} style={styles.button}
                />
              </TouchableOpacity>
              <TouchableOpacity style={styles.button}>
                <Button
                  title="Click to un-register push"
                  color="#9C2542"
                  onPress={onPressUnregisterPush} style={styles.button}
                />
              </TouchableOpacity>
            </View>

            <View style={styles.sectionContainer}>
              <Text style={styles.sectionTitle}>Step One</Text>
              <Text style={styles.sectionDescription}>
                Edit <Text style={styles.highlight}>App.js</Text> to change this
                screen and then come back to see your edits.
              </Text>
            </View>
            <View style={styles.sectionContainer}>
              <Text style={styles.sectionTitle}>See Your Changes</Text>
              <Text style={styles.sectionDescription}>
                <ReloadInstructions />
              </Text>
            </View>
            <View style={styles.sectionContainer}>
              <Text style={styles.sectionTitle}>Debug</Text>
              <Text style={styles.sectionDescription}>
                <DebugInstructions />
              </Text>
            </View>
            <View style={styles.sectionContainer}>
              <Text style={styles.sectionTitle}>Learn More</Text>
              <Text style={styles.sectionDescription}>
                Read the docs to discover what to do next:
              </Text>
            </View>
            <LearnMoreLinks />
          </View>
        </ScrollView>
      </SafeAreaView>
    </>
  );
};

const styles = StyleSheet.create({
  scrollView: {
    backgroundColor: Colors.lighter,
  },
  engine: {
    position: 'absolute',
    right: 0,
  },
  body: {
    backgroundColor: Colors.white,
  },
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
    color: Colors.black,
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
    color: Colors.dark,
  },
  highlight: {
    fontWeight: '700',
  },
  footer: {
    color: Colors.dark,
    fontSize: 12,
    fontWeight: '600',
    padding: 4,
    paddingRight: 12,
    textAlign: 'right',
  },
  button: {
    marginBottom: 10,
  },
  buttons: {
    flexDirection: 'column',
  }
});

export default App;
