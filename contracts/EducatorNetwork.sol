pragma solidity ^0.5.0;
import "../installed_contracts/Strings.sol";
import "../installed_contracts/zeppelin/contracts/math/SafeMath.sol";
//import "github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/math";

contract EducatorNetwork {
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
    
    string[9] languages = ["mandarin", "english", "spanish", "hindi", "arabic", "russian", "portuguese", "french", "italian"];
    mapping(uint => Video) internal videos;
    uint private videoCount = 0;
    
    event LogVideoAdded(uint videoId, string description, string IPFSlocation);
    event LogTranslationAdded(uint videoId, string language, string IPFSlocation);
    event LogVideoPurchased(uint videoId);
    event LogTranslationPurchased(uint videoId, string language);
    
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
    
    modifier isExistingVideo(uint videoId){
        require(bytes(videos[videoId].IPFSlocation).length != 0, "Video does not exist");
        _;
    }
    
    modifier isExistingTranslation(uint videoId, string memory language){
        require(bytes(videos[videoId].translations[language].IPFSlocation).length != 0, "No translation for that language yet.");
        _;
    }
    
    modifier checkValue(uint _videoId, uint _price){
        require(msg.value >= _price, "Not enough funds");
        _;
        msg.sender.transfer(uint256(msg.value) - uint256(_price));
    }
    
    modifier alreadyPurchasedVideo(uint _videoId){
        require(videos[_videoId].buyers[msg.sender] == false, "You've already purchased this video!");
        _;
    }
    
    modifier alreadyPurchasedTranslation(uint _videoId, string memory _language){
        require(videos[_videoId].translations[_language].tBuyers[msg.sender] == false, "You've already purchased this translation");
        _;
    }
    
    // function addVideo()
    function addVideo(uint _price, string memory _description, string memory _IPFSLocation)
    public 
    returns(uint)
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

    function getVideo(uint _videoId)
    public view isExistingVideo(_videoId)
    returns(address, string memory, uint, string memory)
    {
        return(videos[_videoId].uploader, videos[_videoId].description, videos[_videoId].price, videos[_videoId].IPFSlocation);
    }
   
    function addTranslation(uint _videoId, uint _price, string memory _language, string memory _IPFSLocation)
    public isValidLanguage(_language.lower()) isExistingVideo(_videoId)
    {
        string memory language = _language.lower();
        require(bytes(videos[_videoId].translations[language].IPFSlocation).length == 0, "There's already a translation for that language.");
        videos[_videoId].translations[language].translator = msg.sender;
        videos[_videoId].translations[language].price = _price;
        videos[_videoId].translations[language].IPFSlocation = _IPFSLocation;
        
        emit LogTranslationAdded(_videoId, language, _IPFSLocation);
    }
    
    function getTranslation(uint _videoId, string memory _language)
    public view isValidLanguage(_language.lower()) isExistingTranslation(_videoId, _language.lower())
    returns(address, uint, string memory)
    {
        string memory language = _language.lower();
        return(videos[_videoId].translations[language].translator, videos[_videoId].translations[language].price, videos[_videoId].translations[language].IPFSlocation);
    }
    
    function purchaseVideo(uint _videoId)
    public payable isExistingVideo(_videoId) checkValue(_videoId, videos[_videoId].price) alreadyPurchasedVideo(_videoId)
    returns(string memory)
    {
        videos[_videoId].buyers[msg.sender] = true;
        emit LogVideoPurchased(_videoId);
    }
    
    function purchaseTranslation(uint _videoId, string memory _language)
    public payable isExistingVideo(_videoId) isExistingTranslation(_videoId, _language.lower()) 
    checkValue(_videoId, videos[_videoId].translations[_language.lower()].price) alreadyPurchasedTranslation(_videoId, _language.lower())
    returns(string memory)
    {
        videos[_videoId].buyers[msg.sender] = true;
        emit LogTranslationPurchased(_videoId, _language.lower());
    }
   
}