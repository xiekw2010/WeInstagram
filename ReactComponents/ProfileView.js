'use strict';
 
var React = require('react-native');
var {
  StyleSheet,
  Image, 
  View,
  Text,
  Component
} = React;

class ProfileView extends Component {
 
  render() {
    return (
      <View style={styles.containerHeader}>
        <View style={styles.containerHeaderLeft}>
          <Image style={styles.avartar}/>
        </View>
        <View style={styles.containerHeaderRight}>
          <View style={styles.containerHeaderRightUp}>
            <Text style={styles.name}>xiekw</Text>
          </View>
          <View style={styles.containerHeaderRightDown}>
            <Text style={styles.profile}>pics</Text>
            <Text style={styles.profile}>followings</Text>
            <Text style={styles.profile}>followers</Text>
          </View>
        </View>
      </View>
    );
  }
}

var styles = StyleSheet.create({
  containerHeader: {
    marginTop: 80,
    height: 200,
    flexDirection: 'row',
    backgroundColor: '#777777',
    margin: 20.0
  },

  containerHeaderLeft: {
    flex:1,
    backgroundColor: '#000000',
    justifyContent: 'center'
  },

  avartar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    borderWidth: 1,
    borderColor: '#A333FA',
    alignSelf: 'center',
  },

  name: {
    fontSize: 12,
    textAlign: 'center',
    backgroundColor: '#99FFAA'
  },

  containerHeaderRight: {
    flex: 2,
    flexDirection: 'column',
    backgroundColor: '#09FAFF'
  },

  containerHeaderRightUp: {
    flex: 1,
    flexDirection: 'row',
    backgroundColor: '#F33FCC',
    alignItems: 'center',
    justifyContent: 'space-around'
  },

  containerHeaderRightDown: {
    flex: 2,
    flexDirection: 'row',
    backgroundColor: '#CC2200',
    justifyContent: 'space-around',
    alignItems: 'center'
  },

  profile: {
    fontSize: 11,
    margin: 5,
    backgroundColor: '#11FFCC',
    marginTop: -50
  },

  heading: {
    backgroundColor: '#F8F8F8',
  },

  separator: {
    height: 1,
    backgroundColor: '#DDDDDD'
  },
  image: {
    width: 400,
    height: 300
  },
  price: {
    fontSize: 25,
    fontWeight: 'bold',
    margin: 5,
    color: '#48BBEC'
  },
  title: {
    fontSize: 20,
    margin: 5,
    color: '#656565'
  },
  description: {
    fontSize: 18,
    margin: 5,
    color: '#656565'
  }
});


module.exports = ProfileView;
