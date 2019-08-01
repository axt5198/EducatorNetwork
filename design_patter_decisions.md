# Design Pattern Decisions

Prendi's EducatorNetwork smart contract was designed with the following principles in mind: 

1. **Contract should not hold any eth**

    Instructors will upload videos and translations to the web-app which will generate a IPFS hash after being uploaded to IPFS. They will have to specify a description and a price, (and language for translations). This information gets stored on the ledger with the addVideo and addTranslation functions. 
    Whenever a student wishes to purchase a video or translation, he/she will interact the purchaseVideo/purchaseTranslation function. This function uses the modifier checkValue() to assert that the student has passed a value equal to or greater than the price of the video/translation. The value passed goes directly to the video uploader/translator and not the contract. The modifier checkValue() then refunds any remaining funds to the purchaser.
    This approach dramatically decreases the incentive to attack the contract.  

2. __Modular modifiers will be used throughout the contract__

    A number of modifiers were implemented and used for Prendi's Educator Network:

    isValidLanguage() is used to make sure that a video's translation language is valid. The list of valid languages came from the most widely spoken languages in the world.
    
    isExistingVideo() prevents interacting with a video that has not been properly initialized
    
    isExistingTranslation() prevents interacting with a translation that has not been properly initalized
    
    checkValue() is used to check the value passed against the price of a video or translation. It also refunds the sender any excess value.
    
    notPurchasedVideo() is used to prevent students from purchasing the same video twice
    
    havePurchasedVideo() is used to check a student has purchased a video before purchasing a translation
    
    notPurchasedTranslation() is used to prevent students from purchasing the same translation twice 
    

    The use of modifiers throughout the contract made the code and logic for the functions using them much simpler.

3. __No outside contracts were referenced as a safety measure. All logic is handled in a single contract.__

    Also worth pointing out that no "setter" functions allow address as a parameter. Those functions use msg.sender (avoiding use of tx.origin) to add addresses to the data structures.

4. __Prendi's EducatorNetwork contract uses two libraries for added simplicity and safety.__
    
    Library Strings.sol (@author James Lockhart) contains a number of functions to deal with strings in solidity. Given that solidity lacks a lot of the helper functions for strings, it made a lot of sense to import a library.
    
    compareTo() function compares two strings and returns true if they're equal. This function is used when checking for a valid language.
    
    lower() function converts a string to it's lowercase form. I use this throughout the contract to ensure integrity in the setter functions.

    OpenZeppelin's SafeMath.sol library contains a number of functions that perform integer operations safely.
    I use SafeMath to safely add and substract without worrying about over/underflow issues.

5. __Test-driven delopment__

    A thorough javascript test was written alongside the smart contract to test for many possible edge cases when interacting with the EducatorNetwork contract. More details on the test can be found in the comments of the testfile(educator_network.test.js)

6. __Emit important events__

    A number of events will be emitted for important transactions. The names of the events explain what they do pretty well.
    LogVideoAdded()
    
    LogTranslationAdded()
    
    LogVideoPurchased()
    
    LogTranslationPurchased()
    
    
    These events are emitted as the last step in the function logic after passing all assertions in modifiers and completing the rest of the function logic.
