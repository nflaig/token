pragma solidity ^0.4.19;

import "./ERC721.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

/**
 * @title Contract that issues ERC721 tokens to addresses specified by the owner.
 * @dev The tokens are not transferable and can be burned by the owner.
 * Each token can have a string attached as metadata that can be publicly retrieved.
 */
contract TokenDistribution is ERC721, Ownable {
    
    using SafeMath for uint256;
    
    event NewToken(address _to, uint _tokenId, string _message);
    event BurnToken(uint _tokenId);
    event NotTransferable(string _error);
    
    // Token with optional message as metadata
    struct Token {
        string message;
    }
    
    // Array with all token ids, used for enumeration 
    Token[] internal allTokens;
    
    // Mapping from token ID to owner
    mapping (uint => address) internal tokenToOwner;
    
    // Mapping from owner to number of owned token
    mapping (address => uint) internal ownerTokenCount;
    
    /**
     * @dev Retrieves message attached to token. 
     * @param _tokenId The ID of the token.
     */
    function messageOf(uint _tokenId) external view returns (string) {
        require(tokenToOwner[_tokenId] != address(0));
        
        return allTokens[_tokenId].message;
    }
    
    /**
     * @dev Issues a new token with a optional message (only owner). 
     * @param _to The address to issue the token to.
     * @param _message Attached message as metadata (optional).
     */
    function issueToken(address _to, string _message) external onlyOwner {
        require(_to != address(0));
        
        uint tokenId = allTokens.push(Token(_message)) - 1;
        tokenToOwner[tokenId] = _to;
        ownerTokenCount[_to] = ownerTokenCount[_to].add(1);
        
        NewToken(_to, tokenId, _message);
    }
    
    /**
     * @dev Burns a specific token (only owner). 
     * @param _tokenId The ID of the token.
     */
    function burnToken(uint _tokenId) external onlyOwner {
        require(tokenToOwner[_tokenId] != address(0));
        
        // Clear existing metadata 
        if (bytes(allTokens[_tokenId].message).length != 0) {
            delete allTokens[_tokenId].message;
        }
        
        address owner = tokenToOwner[_tokenId];
        tokenToOwner[_tokenId] = address(0);
        ownerTokenCount[owner] = ownerTokenCount[owner].sub(1);
        
        BurnToken(_tokenId);
    }
    
    /**
     * @dev Gets all tokens of a specific address. 
     * @param _owner The address to get the tokens of.
     */
    function getTokensOf(address _owner) external view returns (uint[]) {
        uint[] memory tokens = new uint[](ownerTokenCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < allTokens.length; i++) {
          if (tokenToOwner[i] == _owner) {
              tokens[counter] = i;
              counter++;
          }
        }
        return tokens;
    }
    
    
    /**
     * @dev Gets the balance of the specified addresss. 
     * @param _owner The address to get the balance of.
     */
    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerTokenCount[_owner];
    }
    
    /**
     * @dev Gets the owner of the specified token ID. 
     * @param _tokenId The ID of the token.
     */
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return tokenToOwner[_tokenId];
    }
    
    /**
     * @dev Fire NotTransferable event to log error and notify that the tokens 
     * of this contract are not transferable.
     */
    function transfer(address _to, uint256 _tokenId) public {
        NotTransferable("The tokens are not transferable!");
    }
    
    /**
     * @dev Fire NotTransferable event to log error and notify that the tokens 
     * of this contract are not transferable.
     */
    function approve(address _to, uint256 _tokenId) public {
        NotTransferable("The tokens are not transferable!");
    }
    
    /**
     * @dev Fire NotTransferable event to log error and notify that the tokens 
     * of this contract are not transferable.
     */
    function takeOwnership(uint256 _tokenId) public {
        NotTransferable("The tokens are not transferable!");
    }
    
}