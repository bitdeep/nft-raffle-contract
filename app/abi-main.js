const abi_main = [
    {
        "inputs": [],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "raffle_id",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "value",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "users",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "total",
                "type": "uint256"
            }
        ],
        "name": "Buy",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "_max_per_user",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "address",
                "name": "_nft",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "_nft_id",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "_price",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "_total",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "index",
                "type": "uint256"
            }
        ],
        "name": "Create_Raffle",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "previousOwner",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "newOwner",
                "type": "address"
            }
        ],
        "name": "OwnershipTransferred",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "raffle_id",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "commission",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "address",
                "name": "winner",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "number",
                "type": "uint256"
            }
        ],
        "name": "Trigger",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "raffle_id",
                "type": "uint256"
            }
        ],
        "name": "buy",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "raffle_id",
                "type": "uint256"
            }
        ],
        "name": "cancel",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_max_per_user",
                "type": "uint256"
            },
            {
                "internalType": "address",
                "name": "_nft",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_nft_id",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_price",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_total",
                "type": "uint256"
            }
        ],
        "name": "create_raffle",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getActiveRaffles",
        "outputs": [
            {
                "components": [
                    {
                        "internalType": "enum Main.STATUS",
                        "name": "status",
                        "type": "uint8"
                    },
                    {
                        "internalType": "uint256",
                        "name": "max_per_user",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "total",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "nft",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "nft_id",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "winner",
                        "type": "address"
                    },
                    {
                        "internalType": "address[]",
                        "name": "users",
                        "type": "address[]"
                    },
                    {
                        "internalType": "uint256",
                        "name": "users_length",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "seller",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "price",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    }
                ],
                "internalType": "struct Main.Raffle[]",
                "name": "",
                "type": "tuple[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getCancelledRaffles",
        "outputs": [
            {
                "components": [
                    {
                        "internalType": "enum Main.STATUS",
                        "name": "status",
                        "type": "uint8"
                    },
                    {
                        "internalType": "uint256",
                        "name": "max_per_user",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "total",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "nft",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "nft_id",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "winner",
                        "type": "address"
                    },
                    {
                        "internalType": "address[]",
                        "name": "users",
                        "type": "address[]"
                    },
                    {
                        "internalType": "uint256",
                        "name": "users_length",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "seller",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "price",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    }
                ],
                "internalType": "struct Main.Raffle[]",
                "name": "",
                "type": "tuple[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getFinishedRaffles",
        "outputs": [
            {
                "components": [
                    {
                        "internalType": "enum Main.STATUS",
                        "name": "status",
                        "type": "uint8"
                    },
                    {
                        "internalType": "uint256",
                        "name": "max_per_user",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "total",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "nft",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "nft_id",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "winner",
                        "type": "address"
                    },
                    {
                        "internalType": "address[]",
                        "name": "users",
                        "type": "address[]"
                    },
                    {
                        "internalType": "uint256",
                        "name": "users_length",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "seller",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "price",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    }
                ],
                "internalType": "struct Main.Raffle[]",
                "name": "",
                "type": "tuple[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "enum Main.STATUS",
                "name": "s",
                "type": "uint8"
            }
        ],
        "name": "getRafflesByStatus",
        "outputs": [
            {
                "components": [
                    {
                        "internalType": "enum Main.STATUS",
                        "name": "status",
                        "type": "uint8"
                    },
                    {
                        "internalType": "uint256",
                        "name": "max_per_user",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "total",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "nft",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "nft_id",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "winner",
                        "type": "address"
                    },
                    {
                        "internalType": "address[]",
                        "name": "users",
                        "type": "address[]"
                    },
                    {
                        "internalType": "uint256",
                        "name": "users_length",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "seller",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "price",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    }
                ],
                "internalType": "struct Main.Raffle[]",
                "name": "",
                "type": "tuple[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "id",
                "type": "uint256"
            }
        ],
        "name": "getUsersByRaffleId",
        "outputs": [
            {
                "internalType": "address[]",
                "name": "",
                "type": "address[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "moreRand",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            },
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            },
            {
                "internalType": "bytes",
                "name": "",
                "type": "bytes"
            }
        ],
        "name": "onERC721Received",
        "outputs": [
            {
                "internalType": "bytes4",
                "name": "",
                "type": "bytes4"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "owner",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "raffles",
        "outputs": [
            {
                "internalType": "enum Main.STATUS",
                "name": "status",
                "type": "uint8"
            },
            {
                "internalType": "uint256",
                "name": "max_per_user",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "total",
                "type": "uint256"
            },
            {
                "internalType": "address",
                "name": "nft",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "nft_id",
                "type": "uint256"
            },
            {
                "internalType": "address",
                "name": "winner",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "users_length",
                "type": "uint256"
            },
            {
                "internalType": "address",
                "name": "seller",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "price",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "renounceOwnership",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "a",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "b",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "c",
                "type": "address"
            }
        ],
        "name": "setFeeRecipient",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "newOwner",
                "type": "address"
            }
        ],
        "name": "transferOwnership",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];
