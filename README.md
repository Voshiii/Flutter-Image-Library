# Voshi's Cloud

My **first** flutter project.
A personal cloud to upload, view, save and delete your files/folders.

## Usage:
- Ngrok: Used on Raspberry pi to serve as a server. Must use the URL provided by them as the 'baseUrl'.
- JWT token in order for each user to access the server and retrieve information.
- In the backend, a decryption is key is used to decrypt uploaded files.

## To implement:
- Increased security.
- Increased error handling.
- Save images.
- Stream uploaded videos.
- View files and images.
- Change storage.
- Change password.
- Authentic design.
(Basically a lot should still be implemented)

## Changes:
- Currently Javascript is being used in the backend, this will not scale well. "Go" will be used to account for scalability.

## Decisions:
- The password is not saved anywhere, it's only hashed. If the user loses their password, they lose access to their files. This decision was made to make the server more secure if it would ever be hacked.