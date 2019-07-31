pragma solidity ^0.5.0;
import "../installed_contracts/Strings.sol";
import "../installed_contracts/zeppelin/contracts/math/SafeMath.sol";
//import "github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/math";

/**
@title A network for educational content and content translations
@author Ayrton Trujillo
@notice You can use this contract to reference content stored on IPFS
@dev Can render content using IPFSLocation hash part of video/translation's data structure
*/
contract EducatorNetwork {
    // Using imported libraries
    using Strings for string;
    using SafeMath for uint;

    struct Video{
        uint price;
        uint videoId;
        address payable uploader;
        string IPFSlocation;
        string description;
        mapping(string => Translation) translations;
        mapping(address => bool) buyers;
    }
    
    struct Translation {
        address payable translator;
        uint price;
        string IPFSlocation;
        mapping(address => bool) tBuyers;
    }
    
    // Valid languages
    string[9] languages = ["mandarin", "english", "spanish", "hindi", "arabic", "russian", "portuguese", "french", "italian"];
    
    mapping(uint => Video) private videos;   // Mapping videoId (uint) to Video Struct
    uint private videoCount = 0;            // Initial videoId
    
    // Logging events for uploads and purchases of videos and translations
    event LogVideoAdded(uint videoId, string description, string IPFSlocation);
    event LogTranslationAdded(uint videoId, string language, string IPFSlocation);
    event LogVideoPurchased(uint videoId);
    event LogTranslationPurchased(uint videoId, string language);
    
    // Check against list of valid languages, uses Strings library compareTo and lower methods
    modifier isValidLanguage(string memory _language){
        bool isValid = false;
        for(uint i = 0; i < languages.length; i++){
            if (_language.compareTo(languages[i])){
                isValid = true;
            }
        }
        require(isValid, "Not a valid translation language");
        _;
    }
    
    // Check that video with passed videoId has been initialized
    modifier isExistingVideo(uint videoId){
        require(bytes(videos[videoId].IPFSlocation).length != 0, "Video does not exist");
        _;
    }
    
    // Check that translation with passed paramenters has been initialized
    modifier isExistingTranslation(uint videoId, string memory language){
        require(bytes(videos[videoId].translations[language].IPFSlocation).length != 0, "No translation for that language yet.");
        _;
    }
    
    // Check msg.value against the price of video/translation. Refunds sender any excess funds after calling method returns
    modifier checkValue(uint _videoId, uint _price){
        require(msg.value >= _price, "Not enough funds");
        _;
        msg.sender.transfer(uint256(msg.value) - uint256(_price));
    }
    
    // Check msg.sender hasn't previously purchased video to avoid double charging
    modifier notPurchasedVideo(uint _videoId){
        require(videos[_videoId].buyers[msg.sender] == false, "You've already purchased this video!");
        _;
    }

    // Check msg.sender has purchased video
    modifier havePurchasedVideo(uint _videoId){
        require(videos[_videoId].buyers[msg.sender] == true, "You have not purchased the corresponding video");
        _;
    }
    
    // Check msg.sender hasn't previously purchased translation to avoid double charging
    modifier notPurchasedTranslation(uint _videoId, string memory _language){
        require(videos[_videoId].translations[_language].tBuyers[msg.sender] == false, "You've already purchased this translation");
        _;
    }
    
    /**
    @notice Initialize a new video; set videoId to current videoCount and increase count; emit LogVideoAdded event
    @param _price Video's desired price, specified by uploader
    @param _description Video's description
    @param _IPFSLocation Hash of location in IPFS
    @return videoId for initialized video
    */
    function addVideo(uint _price, string memory _description, string memory _IPFSLocation)
    public
    returns(uint videoId)
    {
        uint _videoId = videoCount++;
        videos[_videoId].videoId = _videoId;
        videos[_videoId].uploader = msg.sender;
        videos[_videoId].price = _price;
        videos[_videoId].description = _description;
        videos[_videoId].IPFSlocation = _IPFSLocation;

        emit LogVideoAdded(_videoId, _description, _IPFSLocation);
        
        return _videoId;
    }

    /**
    @notice Get information about a specific video
    @param _videoId Reference to existing video
    @return Uploader's address; video's description, price, and IPFS location
    */
    function getVideo(uint _videoId)
    public view
    isExistingVideo(_videoId)
    returns(address uploader, string memory description, uint price, string memory IPFSLocation)
    {
        return(videos[_videoId].uploader, videos[_videoId].description, videos[_videoId].price, videos[_videoId].IPFSlocation);
    }
   
    /**
    @notice Add translation to existing video; emit LogTranslationAdded event
    @param _videoId Reference to existing video
    @param _price Translation's desired price, specified by translator
    @param _language Translation's language
    @param _IPFSLocation Hash of location in IPFS
    */
    function addTranslation(uint _videoId, uint _price, string memory _language, string memory _IPFSLocation)
    public
    isValidLanguage(_language.lower())
    isExistingVideo(_videoId)
    {
        string memory language = _language.lower();
        require(bytes(videos[_videoId].translations[language].IPFSlocation).length == 0, "There's already a translation for that language.");
        videos[_videoId].translations[language].translator = msg.sender;
        videos[_videoId].translations[language].price = _price;
        videos[_videoId].translations[language].IPFSlocation = _IPFSLocation;
        
        emit LogTranslationAdded(_videoId, language, _IPFSLocation);
    }
    
    /**
    @notice Get information about a translation for a specific video
    @param _videoId Reference to existing video
    @param _language Translation's language
    @return Translator's address; translation's price and IPFS location
    */
    function getTranslation(uint _videoId, string memory _language)
    public view
    isValidLanguage(_language.lower())
    isExistingTranslation(_videoId, _language.lower())
    returns(address translator, uint price, string memory IPFSLocation)
    {
        string memory language = _language.lower();
        return(videos[_videoId].translations[language].translator, videos[_videoId].translations[language].price, videos[_videoId].translations[language].IPFSlocation);
    }
    
    /**
    @notice Purchase existing video by passing appropriate msg.value; purchaser's address added to video buyer's list;
    @notice Transfer funds corresponding to price of the video to video uploader; emit LogVideoPurchased event
    @param _videoId Reference to existing video
    */
    function purchaseVideo(uint _videoId)
    public payable
    isExistingVideo(_videoId)
    notPurchasedVideo(_videoId)
    checkValue(_videoId, videos[_videoId].price)
    {
        videos[_videoId].buyers[msg.sender] = true;
        videos[_videoId].uploader.transfer(videos[_videoId].price);
        emit LogVideoPurchased(_videoId);
    }

    /**
    @notice Check msg.sender is in the video's buyers list
    @param _videoId Reference to existing video
    @return true if msg.sender is in video's buyers list; false otherwise
    */
    function didPurchaseVideo(uint _videoId)
    public view
    isExistingVideo(_videoId)
    returns(bool)
    {
        return videos[_videoId].buyers[msg.sender];
    }
    
    /**
    @notice Purchase translation of an existing video for a specific language; add purchaser's address to translation's buyers list
    @notice Transfer funds corresponding to price of the translation to translator; emit LogTranslationPurchased event
    @param _videoId Reference to existing video
    @param _language Translation's language
    */
    function purchaseTranslation(uint _videoId, string memory _language)
    public payable
    isExistingVideo(_videoId)
    havePurchasedVideo(_videoId)
    isExistingTranslation(_videoId, _language.lower())
    notPurchasedTranslation(_videoId, _language.lower())
    checkValue(_videoId, videos[_videoId].translations[_language.lower()].price)
    {
        videos[_videoId].translations[_language.lower()].tBuyers[msg.sender] = true;
        videos[_videoId].translations[_language.lower()].translator.transfer(videos[_videoId].translations[_language.lower()].price);
        emit LogTranslationPurchased(_videoId, _language.lower());
    }

    /**
    @notice Check msg.sender is in translation's buyers list
    @param _videoId Referenece to existing video
    @param _language Translation's language
    @return true if msg.sender in translation's buyers list; false otherwise
    */
    function didPurchaseTranslation(uint _videoId, string memory _language)
    public view
    isExistingVideo(_videoId)
    isExistingTranslation(_videoId, _language.lower())
    returns(bool)
    {
        return videos[_videoId].translations[_language.lower()].tBuyers[msg.sender];
    }
}