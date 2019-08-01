Welcome to Prendi!

Prendi is an Educator Network where educators and subject matter experts can upload their digital content. Interested learners can purchase the course directly from the instructors in a decentralized fashion using the Ethereum network.

The platform's goal is to expand the reach of educational content to the whole world by allowing translators to upload a translation for uploaded content. Learners can also purchase these translations to improve their understanding.  


This is a truffle project!

Make sure you have truffle installed.
`npm install --save truffle`

In order to run and test, you will need an etehreum node.
Easiest way to pull this off is using Ganache. They have a great UI that with the click of a button will create a network for testing.

You can also use their cli. 
`npm install --save ganache-cli
ganache-cli`

Make sure the port in the truffle-config.js matches the port of the ganache network. (7545 for Ganache UI)

`truffle compile` will compile the smart contracts
`truffle migrate` will migrate smart contracts to the network
`truffle test` will run all tests in test/educator_network.test.js 

Test-driven development was the approach followed in this project and the test file will give a good overview of the desired functionality.


User Interface

The UI for Prendi is found on the client folder.
From client/src run `npm install` to install all required packages
`npm run start` will start local environment