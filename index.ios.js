'use strict';
var React = require('react-native');
var SearchPage = require('./ReactComponents/SearchPage')
var ProfileView = require('./ReactComponents/ProfileView')

var IgSessionManager = require

class PropertyFinderApp extends React.Component {
  render() {
    return (
      <React.NavigatorIOS
        style={styles.container}
        initialRoute={{
          title: 'Property Finder',
          component: ProfileView,
        }}/>
    );
  } 
}

var styles = React.StyleSheet.create({
  text: {
    color: 'black',
    backgroundColor: 'white',
    fontSize: 30,
    margin: 80,
  },
  container: {
    flex: 1
  }
});


React.AppRegistry.registerComponent('WeInstagram', function() { return PropertyFinderApp});