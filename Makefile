-include .env

deploy:; forge script script/FirstNftDeployer.s.sol:FirstNftDeployer --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast --verify --etherscan-api-key $(KEY)
approve:; forge script script/Interactions.s.sol:Approve --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast 
updateTokenIdLimit:; forge script script/Interactions.s.sol:UpdateTokenIdLimit  --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast 
burnNft:; forge script script/Interactions.s.sol:BurnNft  --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast 
tokenUri:; forge script script/Interactions.s.sol:TokenUri  --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast 
transferNftFrom:; forge script script/Interactions.s.sol:TransferNftFrom  --rpc-url $(SEPOLIA) --account thirdAccount --sender $(ADDR1) --broadcast 
transferNft:; forge script script/Interactions.s.sol:TransferNft  --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast 
mintNft:; forge script script/Interactions.s.sol:MintNft  --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast 
