[![Build Status](https://secure.travis-ci.org/bitpay/copay.png)](http://travis-ci.org/bitpay/copay)

# Copay

## Installation:

```
git clone https://github.com/bitpay/copay.git
cd copay
```

Install bower and grunt if you haven't already:
```
npm install -g bower
npm install -g grunt-cli
```

Build Copay:
```
npm install
bower install
grunt shell --target=dev
```

Open Copay:
```
npm start
```

Then visit localhost:3000 in your browser.


## Running copay
To run on a different port:
```
PORT=3001 npm start
```

To open up five different instances to test 3-of-5 multisig with yourself, then run this in 5 different terminals:
```
PORT=3001 npm start
PORT=3002 npm start
PORT=3003 npm start
PORT=3004 npm start
PORT=3005 npm start
```

To open n different instances more easily, just run:
```
n=5
node launch.js $n &
```

To require Copay as a module for use within you application:

```js
require('copay').start(3000, function(location) {
  console.log('Copay server running at: ' + location);
});

```


## Configuration

Default configuration can be found in the config.js file.
See config.js for more info on configuration options.


# Development

## Google Chrome Extension
When you need to compile a *Chrome Extension* of Copay, you only need to run:
```
$ sh chrome/build.sh
```

- The ZIP file is *chrome/copay-chrome-extension.zip*

## Firefox Add-on
System Requirements

* Download [Add-on SDK](https://addons.mozilla.org/en-US/developers/builder)
* Install it. [Mozilla Docs](https://developer.mozilla.org/en-US/Add-ons/SDK/Tutorials/Installation)

Run

```
$ sh firefox/build.sh
```

- Copy the content of *firefox/firefox-addon* (lib, data, package.json) to your development path.
- Compile the XPI file. [Mozilla Docs](https://developer.mozilla.org/en-US/Add-ons/SDK/Tutorials/Getting_started)

##Web App
The Web App is a clean version of Copay, only the neededs files (html, css, js)
for run Copay locally or in your own server.

In order to get the ZIP file of Copay, you just need to run:
```
$ sh webapp/build.sh
```

- The ZIP file is *webapp/download/copay.zip*
- The *webapp/copay-webapp* is the unzipped version


# About Copay

General
-------

*Copay* implements a multisig wallet using p2sh addresses. It supports multiple wallet configurations, such as 3-of-5
(3 required signatures from 5 participant peers) or 2-of-3.  To create a multisig wallet shared between multiple participants,
*Copay* needs the public keys of all the wallet participants. Those public keys are incorporated into the
wallet configuration and are combined to generate a payment address with which funds can be sent into the wallet.  

To unlock the payment and spend the wallet's funds, a quorum of participant signatures must be collected
and assembled in the transaction. The funds cannot be spent without at least the minimum number of
signatures required by the wallet configuration (2 of 3, 3 of 5, 6 of 6, etc).
Each participant manages their own private key, and that private key is never transmitted anywhere.
Once a transaction proposal is created, the proposal is distributed among the
wallet participants for each participant to sign the transaction locally.
Once the transaction is signed, the last signing participant will broadcast the
transaction to the Bitcoin network using a public API (defaults to the Insight API).

*Copay* also implements BIP32 to generate new addresses for the peers. The public key each participant contributes
to the wallet is a BIP32 extended public key. As additional public keys are needed for wallet operations (to produce
new addresses to receive payments into the wallet, for example) new public keys can be derived from the participants'
original extended public keys. Each participant keeps their own private keys locally. Private keys are not shared.
Private keys are used to sign transaction proposals to make a payment from the shared wallet.

Serverless web
--------------
*Copay* software does not need an application server to run. All the software is implemented in client-side
JavaScript. For persistent storage, the client browser's *localStorage* is used. Locally stored data is
encrypted using a password provided by the local user. Data kept in browser local storage should be
backed up for safekeeping using one of the methods provided by *Copay*, such as downloading the data into a file.  
Without a proper backup of the user's private key data, all funds stored in the
wallet may be lost or inaccessible if the browser's localStorage is deleted, the browser uninstalled,
the local hard disk fails, etc.

Peer communications
-------------------
*Copay* uses peer-to-peer (p2p) networking to communicate between wallet participants. Participants exchange transaction
proposals, public keys, nicknames and information about the wallet configuration. Private keys are *not* shared with anyone.

*Copay* network communications use the webRTC protocol. A p2p facilitator server is needed to enable the peers to find each other.
 *Copay* uses the open-sourced *peerjs* server implementation for p2p discovery. Wallet participants can use a
 public peerjs server or install their own. Once the peers find each other, a true p2p connection is established between the
 peers and there is no further flow of information to the p2p discovery server.

webRTC uses DTLS to secure communications between the peers, and each peer uses a self-signed
certificate.

Security model
--------------
On top of webRTC, *Copay* peers authenticate as part of the "wallet ring"(WR) using an identity
key and a network key.

The *identity key* is a ECDSA public key derived from the participant's extended public
key using a specific BIP32 branch. This special public key is never used for Bitcoin address creation, and
should only be known by members of the WR.
In *Copay* this special public key is named *copayerId*.  The copayerId is hashed and the hash is used to
register with the peerjs server. Registering with a hash avoids disclosing the copayerId to parties outside of the WR.
Peer discovery is accomplished using only the hashes of the WR members' copayerIds. All members of the WR
know the full copayerIds of all the other members of the WR.

The *network key* is a random key generated and distributed among the wallet members during wallet creation.
The network key is stored by each peer in the wallet configuration. The network key is used in establishing a CCM/AES
authenticated encrypted channel between all members of the WR, on top of webRTC. Use of this
*network key* prevents man-in-the-middle attacks from a compromised peerjs server.

Secret String
-------------
When a wallet is created, a secret string is provided to invite new peers to the new wallet. This string
has the following format:

  - CopayerId of the peer generating the string. This is a 33 byte ECDSA public key, as explained above.
This allows the receiving peer to locate the generating peer.
  - Network Key. A 8 byte string to encrypt and sign the peers communication.

The string is encoded using Bitcoin's Base58Check encoding, to prevent transmission errors.

Peer Authentication
-------------------

It is important to note that - except for private keys - *all data* in the wallet is shared with *all members of the wallet*.
Private keys are never shared with anyone and are never sent over the network. There are no *private* messages between
individual members of the wallet. All members of a wallet see everything that happens in that wallet.
